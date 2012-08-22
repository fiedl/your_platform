class Page < ActiveRecord::Base

  attr_accessible        :content, :title

  is_structureable       ancestor_class_names: %w(Page User Group), descendant_class_names: %w(Page User Group)
  is_navable

  has_many :attachments, as: :parent, dependent: :destroy


  # Association Related Methods
  # ----------------------------------------------------------------------------------------------------

  # This return alls attachments of a certain type. 
  # +type+ could be something like `image` or `pdf`. It will be compared to the attachments' mime type. 
  #
  def attachments_by_type( type )
    attachments.find_by_type type
  end


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
    Page.find_by_flag( :intranet_root )
  end

end
