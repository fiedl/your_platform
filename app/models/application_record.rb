class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Caching
  include ReadOnlyMode
  include RecordUrl
  include BestInPlaceCorrections

  # Shortcut for global id.
  # The reverse is: `GlobalID::Locator.locate gid`.
  #
  def gid
    to_global_id.to_s
  end

  # Patch the `#first` method to allow the following for STI classes
  # like `Group`, which has descendant classes like `Groups::Everyone`.
  #
  # - `Group.first` should return the first group regardless of the type,
  #   i.e. `Groups::Everyone` might be the first group.
  # - `Groups::Everyone` should return the first group of the subclass
  #   type.
  #
  def self.first
    if self.column_names.include?('type') && (self != self.base_class)
      self.where(type: self.name).first
    else
      super
    end
  end

  # We have several databases that need synchronizing.
  # The primary database, which is always considered to contain the
  # correct data, is the sql database.
  # From there, we export data to a graph database and
  # later to ldap.
  #
  def sync
    sync_to_graph_database if respond_to? :sync_to_graph_database
  end

end