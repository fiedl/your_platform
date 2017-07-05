require 'active_record/active_record_cache_extension'

ActiveRecord::Base.send(:include, ::ActiveRecordCacheExtension)