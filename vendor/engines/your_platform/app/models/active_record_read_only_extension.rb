module ActiveRecordReadOnlyExtension
  extend ActiveSupport::Concern
  
  def destroy
    raise 'Read-Only Mode' if readonly?
    super
  end
  
  module ClassMethods
    def read_only_mode?
      (@@read_only_mode ||= File.exist?(File.join(Rails.root, 'tmp/read_only_mode')).to_s) == 'true'
    end
  end
end

module ActiveRecord
  class Base
    def readonly?
      ActiveRecord::Base.read_only_mode?
    end
  end
end