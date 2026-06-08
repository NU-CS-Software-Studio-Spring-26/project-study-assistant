class AssignmentsController < ApplicationController
  before_action :require_login
  before_action :set_assignment, only: %i[ show edit update destroy ]

  def index
    @query = params[:q].to_s.strip
    @sort = params[:sort].presence || "due_asc"
    @hide_past_due = params.key?(:hide_past_due) ? params[:hide_past_due] == "1" : true
    @assignments = current_user.assignments

    if @query.present?
      escaped_query = ActiveRecord::Base.sanitize_sql_like(@query)
      @assignments = @assignments.where("title ILIKE :query OR course_name ILIKE :query", query: "%#{escaped_query}%")
    end

    @assignments = @assignments.where(course_name: params[:course]) if params[:course].present?
    @assignments = @assignments.where("estimated_hours <= ?", params[:max_hours].to_i) if params[:max_hours].present?
    @assignments = @assignments.where("due_date >= ?", Time.current) if @hide_past_due

    sorted = case @sort
    when "due_desc"   then @assignments.order(due_date: :desc)
    when "hours_asc"  then @assignments.order(estimated_hours: :asc)
    when "hours_desc" then @assignments.order(estimated_hours: :desc)
    else @assignments.order(due_date: :asc)
    end
    @pagy, @assignments = pagy(sorted)
  end

  def show
  end

  def new
    @assignment = current_user.assignments.new
  end

  def edit
  end

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

  def study_plan
    render json: { plan: StudyPlanSuggestionService.new(current_user).call }
  end

  private

    def set_assignment
      @assignment = current_user.assignments.find(params.expect(:id))
    end

    def assignment_params
      params.expect(assignment: [ :title, :course_name, :due_date, :estimated_hours, :synced_to_calendar, :done ])
    end
end
