#
# This model represents bookmarks. User can bookmark objects by clicking on a star beside
# the object's title. Their bookmarks are listed for them in a quick menu, thus
# users have quick access to bookmarked objects.
#
# Such bookmarkable objects may be other users, or pages, groups, et cetera.
#
class Bookmark < ApplicationRecord

  belongs_to :bookmarkable, polymorphic: true
  belongs_to :user


  # Finder Methods
  # ==========================================================================================

  def self.find_by( args )
    if args[ :user ].present?
      user = args[ :user ]
      args[ :user_id ] = user.id
      args.delete( :user )
    end
    if args[ :bookmarkable ].present?
      bookmarkable = args[ :bookmarkable ]
      args[ :bookmarkable_id ] = bookmarkable.id
      args[ :bookmarkable_type ] = bookmarkable.class.name
      args.delete( :bookmarkable )
    end
    super args
  end

  def self.find_by_user_and_bookmarkable( user, bookmarkable )
    (self.find_all_by_user( user ).find_all_by_bookmarkable( bookmarkable )).first
  end

  def self.find_all_by_user( user )
    self.where( :user_id => user.id )
  end

  def self.find_all_by_bookmarkable( bookmarkable )
    self.where( :bookmarkable_type => bookmarkable.class.name, :bookmarkable_id => bookmarkable.id )
  end


  # API Export // Data Serialization
  # ==========================================================================================
  #
  # Include some associated data in serialized representations of this object,
  # since this additional information is most likely required by the API and
  # external components.
  #
  def serializable_hash( options = {} )
    options.merge!(
                   {
                     :include => {
                       :bookmarkable => {
                         :methods => [ :title, :url ]
                       }
                     }
                   } )
    super( options )
  end

end


