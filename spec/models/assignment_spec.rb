require "rails_helper"

RSpec.describe Assignment, type: :model do
  describe "valid assignment" do
    it "is valid with proper attributes" do
      expect(build(:assignment)).to be_valid
    end
  end

  describe "title validations" do
    it "is invalid without a title" do
      assignment = build(:assignment, title: "")
      expect(assignment).not_to be_valid
      expect(assignment.errors[:title]).to be_present
    end

    it "is invalid with a title over 255 characters" do
      assignment = build(:assignment, title: "a" * 256)
      expect(assignment).not_to be_valid
      expect(assignment.errors[:title]).to be_present
    end

    it "is invalid with profanity in the title" do
      assignment = build(:assignment, title: "shit homework")
      expect(assignment).not_to be_valid
      expect(assignment.errors[:title]).to include("contains inappropriate language")
    end
  end

  describe "course_name validations" do
    it "is invalid without a course_name" do
      assignment = build(:assignment, course_name: "")
      expect(assignment).not_to be_valid
      expect(assignment.errors[:course_name]).to be_present
    end
  end

  describe "due_date validations" do
    it "is invalid without a due_date" do
      assignment = build(:assignment, due_date: nil)
      expect(assignment).not_to be_valid
      expect(assignment.errors[:due_date]).to be_present
    end
  end
end
