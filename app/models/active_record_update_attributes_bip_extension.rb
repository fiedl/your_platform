# This module overrides the regular `update_attributes` method in order to
# fix some issues with best_in_place. For unknown reasons, best_in_place keeps
# sending post requests with empty strings — without pattern we could recognize,
# so far. Therefore, this hack is a quick fix to avoid accidental data loss
# until we have fixed the real issue, which is on the view/js side, really.
#
module ActiveRecordUpdateAttributesBipExtension
  extend ActiveSupport::Concern

  # Definition of the original method:
  # http://apidock.com/rails/v4.2.1/ActiveRecord/Persistence/update, former:
  # http://apidock.com/rails/v3.2.13/ActiveRecord/Persistence/update_attributes
  #
  def update_attributes(attributes)
    # We allow `nil`, but we do not allow "" (empty string).
    non_empty_attributes = attributes.select { |key, value| value != "" }
    super(non_empty_attributes)
  end

  module ClassMethods
  end

end

ActiveRecord::Base.send(:include, ActiveRecordUpdateAttributesBipExtension)
