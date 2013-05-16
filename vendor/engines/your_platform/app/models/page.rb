class Page < ActiveRecord::Base

  attr_accessible        :content, :title, :redirect_to

  is_structureable       ancestor_class_names: %w(Page User Group), descendant_class_names: %w(Page User Group)
  is_navable

  has_many :attachments, as: :parent, dependent: :destroy
  
  belongs_to :author, :class_name => "User", foreign_key: 'author_user_id'


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


  # Blog Entries
  # ----------------------------------------------------------------------------------------------------

  # This method returns all Page objects that can be regarded as blog entries of self.
  # Blog entries are simply child pages of self.
  # 
  # Page: "My Blog"
  #   |------------------ Page: "Entry 1"
  #   |------------------ Page: "Entry 2"
  #
  def blog_entries
    self.child_pages.order('created_at DESC')
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

  def self.find_or_create_root
    self.find_root || self.create_root
  end

  def self.create_root
    root_page = Page.create(title: "Root")
    root_page.add_flag :root
    n = root_page.nav_node; n.slim_menu = true; n.save; n = nil
    return root_page
  end

  def self.find_intranet_root
    Page.find_by_flag( :intranet_root )
  end

  def self.find_or_create_intranet_root
    self.find_intranet_root || self.create_intranet_root
  end

  def self.create_intranet_root
    root_page = Page.find_by_flag :root
    intranet_root = root_page.child_pages.create(title: "Intranet")
    intranet_root.add_flag :intranet_root
    return intranet_root
  end

end
