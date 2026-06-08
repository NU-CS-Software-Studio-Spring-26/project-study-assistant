class UsersController < ApplicationController
  before_action :require_login, except: %i[ new create ]
  before_action :set_user, only: %i[ show edit update destroy sync_ical ]
  before_action :ensure_current_user, only: %i[ show edit update destroy sync_ical ]

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        IcalSyncService.new(@user).sync if @user.ical_url.present?
        format.html { redirect_to dashboard_path }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        IcalSyncService.new(@user).sync if @user.ical_url.present?
        format.html { redirect_to assignments_path, notice: "Canvas calendar synced.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy!

    respond_to do |format|
      reset_session
      format.html { redirect_to root_path, notice: "Account deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def sync_ical
    result = IcalSyncService.new(@user).sync
    if result.success?
      redirect_to assignments_path, notice: "Imported #{result.imported} assignments. Updated #{result.updated}. Skipped #{result.skipped_events} calendar events."
    else
      redirect_to user_path(@user), alert: "Canvas calendar sync could not finish. Check your iCal URL and try again."
    end
  end

  private

    def set_user
      @user = User.find(params.expect(:id))
    end

    def user_params
      permitted = params.expect(user: [ :name, :email, :ical_url, :password, :password_confirmation, :avatar, :accept_terms ])
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
