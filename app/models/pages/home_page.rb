# This class represents a special class of Pages, so called Home Pages,
# which are the entry point pages of public websites managed with
# YourPlatform.
#
class Pages::HomePage < Page

  delegate :layout, :layout=,
    :home_page_title, :home_page_title=,
    :home_page_sub_title, :home_page_sub_title=,
    to: :settings

  # The home page can be associated with a group
  # that is represented by that homepage, for example
  # a sub-organization.
  #
  # The group is found by browsing the profile fields of the
  # groups. If the domain of this home page is entered as
  # home page profile field for a group, that's our group.
  #
  def group
    Group.find group_id if group_id
  end

  def group_id
    return nil if self.root?
    profileable = ProfileFields::Homepage.where('value LIKE ?', "%#{domain}%").first.try(:profileable)
    profileable.kind_of?(Group) ? profileable.id : nil
  end

  # The domain of the home page is taken from the left-most
  # breadcrum element, i.e. the breadcrumb entry of this
  # page.
  #
  #   example.com > About us
  #   ~~~~~~~~~~~
  #
  def domain
    self.nav_node.breadcrumb_item
  end

  # The home pages are always public, i.e. can be seen by anyone on the
  # internet.
  #
  def public?
    true
  end

  # The home page root of a home page is the home page itself,
  # since it is its own breadcrumb root.
  #
  def home_page
    self
  end

  # These child pages are shown in the horizontal nav.
  #
  def horizontal_nav_child_pages
    self.child_pages.select { |p| p.show_in_menu? }
  end

  # To save us from managing separate routes and controllers for this
  # subclass, override the model name.
  #
  def self.model_name
    Page.model_name
  end

end