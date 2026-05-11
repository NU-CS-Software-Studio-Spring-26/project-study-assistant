class AssignmentsController < ApplicationController
  before_action :require_login
  before_action :set_assignment, only: %i[ show edit update destroy ]

  # GET /assignments or /assignments.json
  def index
    @query = params[:q].to_s.strip
    @sort = params[:sort].presence || "due_asc"
    @hide_past_due = params[:hide_past_due] == "1"
    @assignments = current_user.assignments
    if @query.present?
      escaped_query = ActiveRecord::Base.sanitize_sql_like(@query)
      @assignments = @assignments.where("title ILIKE :query OR course_name ILIKE :query", query: "%#{escaped_query}%")
    end
    @assignments = @assignments.where("due_date >= ?", Time.current) if @hide_past_due
    @assignments = @sort == "due_desc" ? @assignments.order(due_date: :desc) : @assignments.order(due_date: :asc)
  end

  # GET /assignments/1 or /assignments/1.json
  def show
  end

  # GET /assignments/new
  def new
    @assignment = current_user.assignments.new
  end

  # GET /assignments/1/edit
  def edit
  end

  # POST /assignments or /assignments.json
  def create
    @assignment = current_user.assignments.new(assignment_params)

    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment, notice: "Assignment was successfully created." }
        format.json { render :show, status: :created, location: @assignment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignments/1 or /assignments/1.json
  def update
    respond_to do |format|
      @assignment.assign_attributes(assignment_params)
      @assignment.due_time_confirmed = true
      @assignment.source = "manual" unless @assignment.imported_from_canvas?

      if @assignment.save
        format.html { redirect_to @assignment, notice: "Assignment was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @assignment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1 or /assignments/1.json
  def destroy
    @assignment.destroy!

    respond_to do |format|
      format.html { redirect_to assignments_path, notice: "Assignment was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def toggle_done
  @assignment = current_user.assignments.find(params[:id])
  @assignment.update(done: !@assignment.done)
  head :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = current_user.assignments.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def assignment_params
      params.expect(assignment: [ :title, :course_name, :due_date, :estimated_hours, :synced_to_calendar,  :done])
    end
end
