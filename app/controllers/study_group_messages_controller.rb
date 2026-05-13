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
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to study_group_path(study_group) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("study_group_#{study_group.id}_messages", partial: "study_group_messages/error", locals: { errors: message.errors.full_messages }) }
        format.html { redirect_to study_group_path(study_group), alert: message.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def study_group_message_params
    params.expect(study_group_message: [ :content ])
  end
end
