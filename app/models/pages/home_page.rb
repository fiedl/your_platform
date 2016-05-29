# This class represents a special class of Pages, so called Home Pages,
# which are the entry point pages of public websites managed with
# YourPlatform.
#
class Pages::HomePage < Page

  delegate :layout, :layout=, to: :settings

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
    cached {
      profileable = ProfileFieldTypes::Homepage.where('value LIKE ?', "%#{domain}%").first.try(:profileable)
      profileable.kind_of?(Group) ? profileable.id : nil
    }
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

  # To save us from managing separate routes and controllers for this
  # subclass, override the model name.
  #
  def self.model_name
    Page.model_name
  end

end