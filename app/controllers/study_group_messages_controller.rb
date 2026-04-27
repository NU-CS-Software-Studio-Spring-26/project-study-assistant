class StudyGroupMessagesController < ApplicationController
  before_action :require_login

  def create
    study_group = StudyGroup.find(params.expect(:study_group_id))
    unless study_group.members.exists?(id: current_user.id)
      redirect_to study_groups_path, alert: "Join this group before posting in chat."
      return
    end

    message = study_group.study_group_messages.new(study_group_message_params)
    message.user = current_user

    if message.save
      redirect_to study_group_path(study_group), notice: "Message sent."
    else
      redirect_to study_group_path(study_group), alert: message.errors.full_messages.to_sentence
    end
  end

  private

  def study_group_message_params
    params.expect(study_group_message: [ :content ])
  end
end
