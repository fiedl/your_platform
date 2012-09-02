# -*- coding: utf-8 -*-

# This extends the your_platform User model.
require_dependency YourPlatform::Engine.root.join( 'app/models/user' ).to_s

# This class represents a user of the platform. A user may or may not have an account.
# While the most part of the user class is contained in the your_platform engine, 
# this re-opened class contains all wingolf-specific additions to the user model.
#
class User

  # This method returns a kind of label for the user, e.g. for menu items representing the user.
  # Use this rather than the name attribute itself, since the title method is likely to be overridden
  # in the main application.
  # Notice: This method does *not* return the academic title of the user.
  # 
  # Here, title returns the name and the aktivitaetszahl, e.g. "Max Mustermann E10 H12".
  # 
  def title
    ( name + "  " + aktivitaetszahl ).strip
  end
  
  # This method returns the bv (Bezirksverband) the user is associated with.
  #
  def bv
    if Bv.all and self.ancestor_groups
      bv_of_this_user = ( Bv.all & self.ancestor_groups ).first
    end
    return bv_of_this_user.becomes Bv if bv_of_this_user
  end

  # This method returns the aktivitaetszahl of the user, e.g. "E10 H12".
  #
  def aktivitaetszahl
    self.corporations.collect do |corporation| 
      year_of_joining = ""
      year_of_joining = corporation.membership_of( self ).created_at.to_s[2, 2] if corporation.membership_of( self ).created_at
      #corporation.token + "\u2009" + year_of_joining
      corporation.token + year_of_joining
    end.join( " " )
  end

end

