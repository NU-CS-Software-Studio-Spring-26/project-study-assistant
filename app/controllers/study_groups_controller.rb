class StudyGroupsController < ApplicationController
  before_action :require_login
  before_action :remove_expired_study_groups
  before_action :set_study_group, only: %i[ show edit update destroy join leave ]
  before_action :ensure_group_member!, only: :show
  before_action :ensure_group_creator!, only: %i[ edit update destroy ]

  def index
    @query = params[:query].to_s.strip
    @study_groups = StudyGroup.includes(:creator, :members).keyword_search(@query).order(start_time: :asc)
  end

  def new
    @study_group = StudyGroup.new
  end

  def show
    @study_group = StudyGroup.includes(:creator, :members, study_group_messages: :user).find(@study_group.id)
    @study_group_message = @study_group.study_group_messages.new(user: current_user)
    @messages = @study_group.study_group_messages.includes(:user).order(:created_at)
  end

  def edit
  end

  def create
    @study_group = StudyGroup.new(study_group_params)
    @study_group.creator = current_user
    @study_group.tags = parsed_tags

    if @study_group.save
      @study_group.group_memberships.find_or_create_by!(user: current_user)
      redirect_to study_group_path(@study_group), notice: "Study group was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @study_group.assign_attributes(study_group_params)
    @study_group.tags = parsed_tags

    if @study_group.save
      redirect_to study_group_path(@study_group), notice: "Study group was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @study_group.destroy!
    redirect_to study_groups_path, notice: "Study group was successfully deleted.", status: :see_other
  end

  def join
    if @study_group.password_protected? && params[:join_password].to_s != @study_group.join_password
      redirect_back fallback_location: study_groups_path, alert: "This group is password-protected. Enter the correct password to join."
      return
    end

    membership = @study_group.group_memberships.find_or_initialize_by(user: current_user)
    if membership.persisted? || membership.save
      redirect_to study_group_path(@study_group), notice: "You joined #{@study_group.name}."
    else
      redirect_back fallback_location: study_groups_path, alert: membership.errors.full_messages.to_sentence
    end
  end

  def leave
    if @study_group.creator == current_user
      redirect_to study_groups_path, alert: "Creators can delete their study group instead of leaving it."
      return
    end

    membership = @study_group.group_memberships.find_by(user: current_user)
    if membership
      membership.destroy!
      redirect_to study_groups_path, notice: "You left #{@study_group.name}."
    else
      redirect_to study_groups_path, alert: "You are not a member of that study group."
    end
  end

  private

  def set_study_group
    @study_group = StudyGroup.find(params.expect(:id))
  end

  def ensure_group_member!
    return if @study_group.members.exists?(id: current_user.id)
    redirect_to study_groups_path, alert: "You need to join this group before you can enter it."
  end

  def ensure_group_creator!
    return if @study_group.creator == current_user

    redirect_to study_groups_path, alert: "Only the creator can change that study group."
  end

  def study_group_params
    params.expect(study_group: [ :name, :start_time, :end_time, :location_mode, :communication_style, :join_password ])
  end

  def parsed_tags
    params[:custom_tags].to_s.split(",").map(&:strip).reject(&:blank?).uniq
  end

  def remove_expired_study_groups
    StudyGroup.where("end_time < ?", Time.current).destroy_all
  end
end
