module SanitizeOverride
  def sanitize_forbidden_attributes(attributes)
    attributes
  end
end

ActiveRecord::Relation.include SanitizeOverride