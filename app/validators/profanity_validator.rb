class ProfanityValidator < ActiveModel::EachValidator
  BLOCKED = %w[
    fuck shit bitch asshole bastard dick cunt pussy slut whore
    nigger nigga faggot fag retard cock damn piss douche
  ].freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    text = value.to_s.downcase
    if BLOCKED.any? { |word| text.match?(/\b#{Regexp.escape(word)}\b/) }
      record.errors.add(attribute, options[:message] || "contains inappropriate language")
    end
  end
end
