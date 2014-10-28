module ProfileHelper
  
  def profile_section(section, profile_field_options = {})
    render partial: 'profiles/section', locals: { section: section, profile_field_options: profile_field_options }
  end
  
  def optional_profile_section(section, options = {})
    profile_section(section, options) if show_this_section?(section)
  end
  
  # options:
  #   - force_show
  # 
  def profile_sections_to_html(sections, options = {})
    sections = sections_to_be_shown(sections) unless options[:force_show]
    sections.collect do |section|
      profile_section(section)
    end.join.html_safe
  end
  
  
  private

  # This method returns all sections to be shown.
  # For further reference, see `show_all_sections?` and `show_this_section?`.
  #
  def sections_to_be_shown( all_sections )
    all_sections.select do |section|
      show_this_section?( section )
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
    can? :update, profileable
  end

  def has_visible_fields?( section )
    section.profile_fields.select{|field| can? :read, field}.count > 0
  end

  # A section is to be shown if
  # (a) the section is not empty, or
  # (b) all sections are to be shown (by force).
  #
  def show_this_section?( section )
    has_visible_fields?(section) or show_all_sections?(section.profileable)
  end

  def map_of_address_profile_fields( address_profile_fields )
    address_profile_fields = address_profile_fields.select do |pf|
      pf.type == "ProfileFieldTypes::Address"
    end
    json = address_profile_fields.to_gmaps4rails
    if json
      gmaps( :markers => { :data => json }, 
             :map_options => { :auto_adjust => true, :auto_zoom => false, :zoom => 5 }
             )   
    end 
  end
  
end
