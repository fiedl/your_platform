class Page < ActiveRecord::Base
  attr_accessible :content, :title
  has_dag_links   link_class_name: 'DagLink', ancestor_class_names: %w(Page User), descendant_class_names: %w(Page User)

  def self.find_root
    p = Page.first
    if p.root?
      p
    else
     p.ancestor_pages.first
    end
  end

end
