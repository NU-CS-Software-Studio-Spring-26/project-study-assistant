require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  test "requires an owner and core assignment fields" do
    assignment = Assignment.new

    assert_not assignment.valid?
    assert_includes assignment.errors[:user], "must exist"
    assert_includes assignment.errors[:title], "can't be blank"
    assert_includes assignment.errors[:course_name], "can't be blank"
    assert_includes assignment.errors[:due_date], "can't be blank"
  end
end
