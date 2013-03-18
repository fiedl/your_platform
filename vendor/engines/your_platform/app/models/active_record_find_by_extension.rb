module ActiveRecordFindByExtension
  extend ActiveSupport::Concern

  module ClassMethods

    # A Rails 4 alias for `where`.
    # See: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/relation/finder_methods.rb
    #
    # It will return the first matching object and return the object, not an ActiveRecord::Relation.
    # If an ActiveRecord::Relation, which is chainable, is needed, use where().
    #
    def find_by( args )
      where( args ).limit( 1 ).first
    end

  end

end

ActiveRecord::Base.send( :include, ActiveRecordFindByExtension ) if Rails.version < "4.0"
