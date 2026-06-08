require "rails_helper"

RSpec.describe StudyGroup, type: :model do
  describe "valid study group" do
    it "is valid with proper attributes" do
      expect(build(:study_group)).to be_valid
    end
  end

  describe "name validations" do
    it "is invalid without a name" do
      group = build(:study_group, name: "")
      expect(group).not_to be_valid
      expect(group.errors[:name]).to be_present
    end

    it "is invalid with a name over 150 characters" do
      group = build(:study_group, name: "a" * 151)
      expect(group).not_to be_valid
      expect(group.errors[:name]).to be_present
    end

    it "is invalid with profanity in the name" do
      group = build(:study_group, name: "shit study group")
      expect(group).not_to be_valid
      expect(group.errors[:name]).to include("contains inappropriate language")
    end
  end

  describe "time validations" do
    it "is invalid when start_time is in the past" do
      group = build(:study_group, start_time: 1.hour.ago, end_time: 1.day.from_now)
      expect(group).not_to be_valid
      expect(group.errors[:start_time]).to include("must be in the future")
    end

    it "is invalid when end_time is before start_time" do
      group = build(:study_group, start_time: 2.days.from_now, end_time: 1.day.from_now)
      expect(group).not_to be_valid
      expect(group.errors[:end_time]).to include("must be after the start time")
    end

    it "is invalid when end_time equals start_time" do
      t = 1.day.from_now
      group = build(:study_group, start_time: t, end_time: t)
      expect(group).not_to be_valid
      expect(group.errors[:end_time]).to be_present
    end
  end

  describe "location_mode and communication_style" do
    it "is invalid with an unlisted location_mode" do
      group = build(:study_group, location_mode: "Carrier Pigeon")
      expect(group).not_to be_valid
    end

    it "is invalid with an unlisted communication_style" do
      group = build(:study_group, communication_style: "Mime")
      expect(group).not_to be_valid
    end
  end
end
