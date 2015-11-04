# In a graph, the DagLinks are the links between the nodes.
# "DAG" stands for directed acyclic graph.
#
# The functionality is mostly extracted from the acts_as_dag gem,
# which we have used earlier:
# https://github.com/resgraph/acts-as-dag/blob/master/lib/dag/dag.rb
#
# Now, in contrast to the gem, we only store direct links in the database.
# Indirect links exist only in memory and in cache. This way, we don't have
# redundancies and inconsistencies anymore.
#
class DagLink < ActiveRecord::Base

  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct if defined? attr_accessible
  has_many_flags
  
  belongs_to :ancestor, :polymorphic => true
  belongs_to :descendant, :polymorphic => true
  
  validates :ancestor_type, :presence => true
  validates :descendant_type, :presence => true
  
  scope :with_ancestor, lambda { |ancestor| where(:ancestor_id => ancestor.id, :ancestor_type => ancestor.class.to_s) }
  scope :with_descendant, lambda { |descendant| where(:descendant_id => descendant.id, :descendant_type => descendant.class.to_s) }

  scope :with_ancestor_point, lambda { |point| where(:ancestor_id => point.id, :ancestor_type => point.type) }
  scope :with_descendant_point, lambda { |point| where(:descendant_id => point.id, :descendant_type => point.type) }

  scope :ancestor_nodes, lambda { joins(:ancestor) }
  scope :descendant_nodes, lambda { joins(:descendant) }
  
  validates :ancestor, :presence => true
  validates :descendant, :presence => true
  
  before_validation :fill_defaults, :on => :update
  before_validation :fill_defaults, :on => :create
    
  # We have to workaround a bug in Rails 3 here. But, since Rails 3 is no longer fully supported,
  # this is not going to be fixed.
  # 
  # https://github.com/rails/rails/issues/7618
  #
  # With our workaround, the `delete_cache` method is called on the `DagLink` when
  # `group.members.destroy(user)` is called.
  # 
  # See: app/models/active_record_associations_patches.rb
  #
  after_save { self.delay.delete_cache }
  before_destroy :delete_cache
  
  include DagLinkValidityRange
  
  def fill_cache
    valid_from
  end

  def delete_cache
    super
    ancestor.try(:delete_cache)
    descendant.try(:delete_cache)
  end
  
  # These are defaults that are needed while migrating from the 
  # acts_as_dag gem to the new mechanism.
  #
  def fill_defaults
    self.direct = true if self.direct.nil?
    self.count = 0 if self.count.nil?
  end
  
end
