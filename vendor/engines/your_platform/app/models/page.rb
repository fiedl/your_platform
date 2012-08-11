class Page < ActiveRecord::Base

  attr_accessible        :content, :title

  is_structureable       ancestor_class_names: %w(Page User Group), descendant_class_names: %w(Page User Group)
  is_navable

  # Finder Methods
  # ----------------------------------------------------------------------------------------------------
  
  def self.find_root
    p = Page.first
    if p
      if p.root?
        p
      else
        p.ancestor_pages.first
      end
    end
  end

  def self.find_intranet_root
    if self.find_root
      self.find_root.child_pages.select { |page| page.title == "Mitglieder Start" }.first
    end
  end

end
