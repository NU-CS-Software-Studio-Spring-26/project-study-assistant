class StudyGroupMessagesController < ApplicationController
  def create
    study_group = StudyGroup.find(params.expect(:study_group_id))
    message = study_group.study_group_messages.new(study_group_message_params)

    if message.save
      redirect_to study_group_path(study_group), notice: "Message sent."
    else
      redirect_to study_group_path(study_group), alert: message.errors.full_messages.to_sentence
    end
  end

  private

  def study_group_message_params
    params.expect(study_group_message: [ :user_id, :content ])
  end
end
