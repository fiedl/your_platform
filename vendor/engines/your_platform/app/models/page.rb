class Page < ActiveRecord::Base

  attr_accessible        :content, :title, :redirect_to

  is_structureable       ancestor_class_names: %w(Page User Group), descendant_class_names: %w(Page User Group)
  is_navable

  has_many :attachments, as: :parent, dependent: :destroy


  # Redirection
  # ----------------------------------------------------------------------------------------------------

  def redirect_to

    # http://example.com
    return super if super.kind_of?(String) && super.include?("://")

    # users#index
    if super.kind_of?(String) && super.include?("#")
      controller, action = super.split("#")           
      return { controller: controller, action: action } if controller && action
    end

    # { controller: "users", action: "index" }
    return super if super.kind_of? Hash

    # else
    return nil
  end



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
