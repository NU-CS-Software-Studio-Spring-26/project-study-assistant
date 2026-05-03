class UsersController < ApplicationController
  before_action :require_login, except: %i[ new create ]
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :ensure_current_user, only: %i[ show edit update destroy ]

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        IcalSyncService.new(@user).sync
        session[:user_id] = @user.id
        format.html { redirect_to dashboard_path, notice: "Account created. Welcome to Study Assistant." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        IcalSyncService.new(@user).sync
        format.html { redirect_to @user, notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      reset_session
      format.html { redirect_to root_path, notice: "Account deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_params
      permitted = params.expect(user: [ :name, :email, :ical_url, :password, :password_confirmation ])
      if permitted[:password].blank? && permitted[:password_confirmation].blank?
        permitted.except(:password, :password_confirmation)
      else
        permitted
      end
    end

    def ensure_current_user
      return if @user == current_user

      redirect_to dashboard_path, alert: "You can only access your own account."
    end
end
