class StudyGroupsController < ApplicationController
  before_action :require_login
  before_action :set_study_group, only: [ :show, :join ]
  before_action :ensure_group_member!, only: :show

  def index
    @study_group = StudyGroup.new
    @study_groups = StudyGroup.includes(:creator, :members).order(study_time: :asc)
  end

  def show
    @study_group = StudyGroup.includes(:creator, :members, study_group_messages: :user).find(@study_group.id)
    @study_group_message = @study_group.study_group_messages.new(user: current_user)
    @messages = @study_group.study_group_messages.includes(:user).order(:created_at)
  end

  def create
    @study_group = StudyGroup.new(study_group_params)
    @study_group.creator = current_user
    @study_group.tags = parsed_tags

    if @study_group.save
      @study_group.group_memberships.find_or_create_by!(user: current_user)
      redirect_to study_groups_path, notice: "Study group was successfully created."
    else
      @study_groups = StudyGroup.includes(:creator, :members).order(study_time: :asc)
      render :index, status: :unprocessable_entity
    end
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

  private

  def set_study_group
    @study_group = StudyGroup.find(params.expect(:id))
  end

  def ensure_group_member!
    return if @study_group.members.exists?(id: current_user.id)
    redirect_to study_groups_path, alert: "You need to join this group before you can enter it."
  end

  def study_group_params
    params.expect(study_group: [ :name, :study_time, :location_mode, :communication_style, :join_password, tags: [] ])
  end

  def parsed_tags
    base_tags = study_group_params[:tags].to_a
    custom_tags = params[:extra_tags].to_s.split(",").map(&:strip)
    (base_tags + custom_tags).reject(&:blank?).uniq
  end
end