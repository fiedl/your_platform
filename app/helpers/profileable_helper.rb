module ProfileableHelper
  
  def profile_sections_for_profileable( profileable, sections = [] )
    sections_to_be_shown( sections, profileable ).collect do |section|
      render( partial: 'shared/section', locals: { :profileable => profileable, :section => section } )
    end.join.html_safe
  end

  private

  # This method returns all sections to be shown.
  # For further reference, see `show_all_sections?` and `show_this_section?`.
  #
  def sections_to_be_shown( all_sections, profileable )
    all_sections.select do |section|
      show_this_section?( section, profileable )
    end
  end
  
  # On a profile view, empty sections need not to be shown necessarily. For most users empty sections are of no use.
  # But, users that have admin rights should see that a section is empty -- and of course be encouraged to
  # fill the section with some information.
  #
  # Since there are no admin roles in the system, yet, let's say for now:
  # Show emtpy sections only if the current_user is the user to be displayed,
  # i.e. if somebody looks at his own profile.
  #
  def show_all_sections?( profileable )
    ( profileable == current_user )
  end

  # A section is to be shown if
  # (a) the section is not empty, or
  # (b) all sections are to be shown (by force).
  #
  def show_this_section?( section, profileable )
    ( profileable.profile_fields_by_section( section ).count > 0 ) or ( show_all_sections?( profileable ) )
  end

  def map_of_address_profile_fields( address_profile_fields )
    json = address_profile_fields.to_gmaps4rails
    gmaps4rails( json ) if json
  end
  
end
