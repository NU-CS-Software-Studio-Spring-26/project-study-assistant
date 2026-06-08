require "rails_helper"

RSpec.describe StudyGroupMessage, type: :model do
  # Set up a group and two users — one who joins, one who does not.
  let(:group)      { create(:study_group) }
  let(:member)     { create(:user) }
  let(:non_member) { create(:user) }

  before { group.group_memberships.create!(user: member) }

  describe "valid message" do
    it "is valid when the user is a member of the group" do
      message = StudyGroupMessage.new(content: "Hey everyone!", user: member, study_group: group)
      expect(message).to be_valid
    end
  end

  describe "content validations" do
    it "is invalid without content" do
      message = StudyGroupMessage.new(content: "", user: member, study_group: group)
      expect(message).not_to be_valid
      expect(message.errors[:content]).to be_present
    end

    it "is invalid with content over 256 characters" do
      message = StudyGroupMessage.new(content: "a" * 257, user: member, study_group: group)
      expect(message).not_to be_valid
      expect(message.errors[:content]).to be_present
    end

    it "is invalid with profanity in content" do
      message = StudyGroupMessage.new(content: "this is shit", user: member, study_group: group)
      expect(message).not_to be_valid
      expect(message.errors[:content]).to include("contains inappropriate language")
    end
  end

  describe "membership validation" do
    it "is invalid when user is not a member of the group" do
      message = StudyGroupMessage.new(content: "Hello!", user: non_member, study_group: group)
      expect(message).not_to be_valid
      expect(message.errors[:user]).to include("must join the group before posting")
    end
  end
end
