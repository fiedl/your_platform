class Page < ActiveRecord::Base
  attr_accessible                :content, :title
  has_dag_links                  link_class_name: 'DagLink', ancestor_class_names: %w(Page User Group), descendant_class_names: %w(Page User Group)

  is_navable
  
  def self.find_root
    p = Page.first
    if p.root?
      p
    else
     p.ancestor_pages.first
    end
  end

  def self.mitglieder_start
    self.find_root.child_pages.select { |page| page.title == "Mitglieder Start" }.first
  end

end
