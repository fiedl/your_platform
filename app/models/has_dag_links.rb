# This defines the ActiveRecord::Base method `has_dag_links`.
#
# Usage:
#
#     class Group < ActiveRecord::Base
#       has_dag_links ancestor_class_names: ['Group'], 
#                     descendant_class_names: ['Group', 'User']
#     end
#
# This code is extracted from the acts_as_dag gem.
# https://github.com/resgraph/acts-as-dag/blob/master/lib/dag/dag.rb
# 
module HasDagLinks
  def has_dag_links(options = {})
    conf = {
            :class_name => nil,
            :ancestor_class_names => [],
            :descendant_class_names => []
    }
    conf.update(options)

    has_many :links_as_ancestor, :as => :ancestor, :class_name => 'DagLink'
    has_many :links_as_descendant, :as => :descendant, :class_name => 'DagLink'
    has_many :links_as_parent, lambda { where(:direct => true) }, :as => :ancestor, :class_name => 'DagLink'
    has_many :links_as_child, lambda { where(:direct => true) }, :as => :descendant, :class_name => 'DagLink'
    
    ancestor_table_names = []
    parent_table_names = []
    conf[:ancestor_class_names].each do |class_name|
      table_name = class_name.tableize
      self.class_eval <<-EOL2
              has_many :links_as_descendant_for_#{table_name}, lambda { where(:ancestor_type => '#{class_name}') }, :as => :descendant, :class_name => 'DagLink'
              has_many :ancestor_#{table_name}, :through => :links_as_descendant_for_#{table_name}, :source => :ancestor, :source_type => '#{class_name}'
              has_many :links_as_child_for_#{table_name}, lambda { where(:ancestor_type => '#{class_name}', :direct => true) }, :as => :descendant, :class_name => 'DagLink'
              has_many :parent_#{table_name}, :through => :links_as_child_for_#{table_name}, :source => :ancestor, :source_type => '#{class_name}'
            	def root_for_#{table_name}?
    						self.links_as_descendant_for_#{table_name}.empty?
          		end
      EOL2
      ancestor_table_names << ('ancestor_'+table_name)
      parent_table_names << ('parent_'+table_name)
      unless conf[:descendant_class_names].include?(class_name)
        #this apparently is only one way is we can create some aliases making things easier
        self.class_eval "has_many :#{table_name}, :through => :links_as_descendant_for_#{table_name}, :source => :ancestor, :source_type => '#{class_name}'"
      end
    end
    
    self.class_eval <<-EOL25
						def ancestors
							#{ancestor_table_names.join(' + ')}
						end
						def parents
							#{parent_table_names.join(' + ')}
						end
    EOL25
    
    descendant_table_names = []
    child_table_names = []
    conf[:descendant_class_names].each do |class_name|
      table_name = class_name.tableize
      self.class_eval <<-EOL3
              has_many :links_as_ancestor_for_#{table_name}, lambda { where(:descendant_type => '#{class_name}') }, :as => :ancestor, :class_name => 'DagLink'
              has_many :descendant_#{table_name}, :through => :links_as_ancestor_for_#{table_name}, :source => :descendant, :source_type => '#{class_name}'
              has_many :links_as_parent_for_#{table_name}, lambda { where(:descendant_type => '#{class_name}', :direct => true) }, :as => :ancestor, :class_name => 'DagLink'
              has_many :child_#{table_name}, :through => :links_as_parent_for_#{table_name}, :source => :descendant, :source_type => '#{class_name}'
    					def leaf_for_#{table_name}?
              	self.links_as_ancestor_for_#{table_name}.empty?
            	end
      EOL3
      descendant_table_names << ('descendant_'+table_name)
      child_table_names << ('child_'+table_name)
      unless conf[:ancestor_class_names].include?(class_name)
        self.class_eval "has_many :#{table_name}, :through => :links_as_ancestor_for_#{table_name}, :source => :descendant, :source_type => '#{class_name}'"
      end
    end
    
    self.class_eval <<-EOL35
						def descendants
							#{descendant_table_names.join(' + ')}
						end
						def children
							#{child_table_names.join(' + ')}
						end
    EOL35
    
  end
end