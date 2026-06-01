require "test_helper"

class StudyPlanSuggestionServiceTest < ActiveSupport::TestCase
  AssignmentStub = Struct.new(:title, :course_name, :due_date, :estimated_hours)

  class RelationStub
    def initialize(assignments)
      @assignments = assignments
    end

    def where(*_args)
      self
    end

    def order(*_args)
      self
    end

    def limit(_value)
      self
    end

    def to_a
      @assignments
    end
  end

  class UserStub
    attr_reader :assignments

    def initialize(assignments)
      @assignments = RelationStub.new(assignments)
    end
  end

  test "returns a local prioritized summary when the API key is missing" do
    user = UserStub.new([
      AssignmentStub.new("Read chapter 4", "BIO 101", Time.zone.local(2026, 6, 2, 18, 0), 2),
      AssignmentStub.new("Problem set 7", "MATH 230", Time.zone.local(2026, 6, 1, 23, 59), 4),
      AssignmentStub.new("Discussion post", "ENG 201", Time.zone.local(2026, 6, 3, 12, 0), 1)
    ])

    service = StudyPlanSuggestionService.new(user)
    plan = service.call

    assert_includes plan, "Top 3 tasks to focus on"
    assert_includes plan, "Study order for the next 24 hours"
    assert_includes plan, "Problem set 7"
  end

  test "falls back to the local summary when the AI request fails" do
    user = UserStub.new([
      AssignmentStub.new("Paper outline", "ENG 201", Time.zone.local(2026, 6, 1, 20, 0), 3)
    ])

    service = StudyPlanSuggestionService.new(user)

    service.stub(:api_key, "test-key") do
      service.stub(:generate_with_openai, ->(_assignments) { raise StandardError, "boom" }) do
        plan = service.call
        assert_includes plan, "Paper outline"
        assert_includes plan, "AI service was unavailable"
      end
    end
  end
end