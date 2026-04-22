class StudyGroupsController < ApplicationController
  def index
    @study_group = StudyGroup.new
    @users = User.order(:name)
    @study_groups = StudyGroup.includes(:creator, :members).order(study_time: :asc)
  end

  def create
    @study_group = StudyGroup.new(study_group_params)
    @study_group.tags = parsed_tags

    if @study_group.save
      @study_group.group_memberships.find_or_create_by!(user_id: @study_group.creator_id)
      redirect_to study_groups_path, notice: "Study group was successfully created."
    else
      @users = User.order(:name)
      @study_groups = StudyGroup.includes(:creator, :members).order(study_time: :asc)
      render :index, status: :unprocessable_entity
    end
  end

  def join
    study_group = StudyGroup.find(params.expect(:id))
    user = User.find(params.expect(:user_id))

    membership = study_group.group_memberships.find_or_initialize_by(user: user)
    if membership.persisted? || membership.save
      redirect_to study_groups_path, notice: "#{user.name} joined #{study_group.name}."
    else
      redirect_to study_groups_path, alert: membership.errors.full_messages.to_sentence
    end
  end

  private

  def study_group_params
    params.expect(study_group: [ :name, :study_time, :location_mode, :communication_style, :creator_id, tags: [] ])
  end

  def parsed_tags
    base_tags = study_group_params[:tags].to_a
    custom_tags = params[:extra_tags].to_s.split(",").map(&:strip)
    (base_tags + custom_tags).reject(&:blank?).uniq
  end
end