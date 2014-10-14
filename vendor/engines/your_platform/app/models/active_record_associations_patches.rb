module ActiveRecordAssociationsPatches
  extend ActiveSupport::Concern
  
  # This fixes a bug in ActiveRecord Association Callbacks.
  # https://github.com/rails/rails/issues/7618
  #
  # For example `group.members.destroy(user)` would not call the `before_destroy` callbacks
  # on the memberships (i.e. the through_records of the HasManyThrough association).
  #
  # But we need the cache deletion to be called. Therefore, we trigger them here manually.
  #
  def destroy(*records)
    if self.class.name == "ActiveRecord::Associations::HasManyThroughAssociation"
      through_association.load_target
      records.each do |record|
        through_records_for(record).each do |through_record|
          through_record.delete_cache if through_record.respond_to? :delete_cache
        end
      end
    end
    super(*records)
  end
  
end

ActiveRecord::Associations::CollectionAssociation.send(:prepend, ActiveRecordAssociationsPatches)
