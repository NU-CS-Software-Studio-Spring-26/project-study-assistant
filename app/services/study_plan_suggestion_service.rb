require "json"
require "net/http"
require "uri"

class StudyPlanSuggestionService
  MAX_ASSIGNMENTS = 8

  def initialize(user)
    @user = user
  end

  def call
    assignments = pending_assignments.limit(MAX_ASSIGNMENTS).to_a
    return "No assignments need attention right now." if assignments.empty?
    return fallback_summary(assignments) if api_key.blank?

    generate_with_openai(assignments)
  rescue StandardError => e
    Rails.logger.warn("Study plan AI unavailable: #{e.class}: #{e.message}")
    fallback_summary(assignments)
  end

  private

  attr_reader :user

  def pending_assignments
    user.assignments.where(done: [false, nil]).order(due_date: :asc, estimated_hours: :desc, created_at: :asc)
  end

  def fallback_summary(assignments)
    prioritized = prioritize(assignments)

    lines = []
    lines << "Top 3 tasks to focus on:"
    prioritized.first(3).each_with_index do |assignment, index|
      lines << "#{index + 1}. #{assignment_brief(assignment)}"
    end

    lines << ""
    lines << "Study order for the next 24 hours:"
    prioritized.first(3).each_with_index do |assignment, index|
      lines << "- Block #{index + 1}: #{assignment.title} for #{assignment.estimated_hours || 1} hour#{assignment.estimated_hours.to_i == 1 ? '' : 's'}"
    end

    if prioritized.length > 3
      lines << "- If you finish early, move to: #{assignment_brief(prioritized[3])}"
    end

    lines << ""
    lines << "This plan was generated locally because the AI service was unavailable."
    lines.join("\n")
  end

  def generate_with_openai(assignments)
    uri = URI(api_base_url)
    request = Net::HTTP::Post.new(uri.request_uri)
    request["Authorization"] = "Bearer #{api_key}"
    request["Content-Type"] = "application/json"
    request.body = {
      model: ENV.fetch("OPENAI_MODEL", "gpt-4.1-mini"),
      messages: [
        { role: "system", content: "You are a concise study planner for students. Return short, practical advice in plain text." },
        { role: "user", content: prompt_for(assignments) }
      ],
      temperature: 0.4
    }.to_json

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    raise "OpenAI request failed with #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    content = JSON.parse(response.body).dig("choices", 0, "message", "content").to_s.strip
    content.present? ? content : fallback_summary(assignments)
  end

  def prompt_for(assignments)
    assignment_lines = assignments.map do |assignment|
      due_text = assignment.due_date ? assignment.due_date.strftime("%a, %b %-d at %-l:%M %p") : "no due date"
      estimated_hours = assignment.estimated_hours || 0
      "#{assignment.title} | #{assignment.course_name} | due #{due_text} | estimated #{estimated_hours}h"
    end

    <<~PROMPT
      Build a short prioritized study plan for the next 24 hours.
      Highlight the top 3 tasks.
      Suggest a simple study order for those tasks.
      Keep it concise and easy to scan.

      Assignments:
      #{assignment_lines.join("\n")}
    PROMPT
  end

  def prioritize(assignments)
    assignments.sort_by do |assignment|
      [
        assignment.due_date || 99.years.from_now,
        -(assignment.estimated_hours || 0),
        assignment.title.to_s.downcase
      ]
    end
  end

  def assignment_brief(assignment)
    due_text = assignment.due_date ? assignment.due_date.strftime("%b %-d, %-I:%M %p") : "no due date"
    estimated_text = assignment.estimated_hours.present? ? "#{assignment.estimated_hours}h" : "unknown time"
    "#{assignment.title} for #{assignment.course_name} due #{due_text} (#{estimated_text})"
  end

  def api_key
    ENV["OPENAI_API_KEY"].to_s.strip
  end

  def api_base_url
    ENV.fetch("OPENAI_BASE_URL", "https://api.openai.com/v1/chat/completions")
  end
end