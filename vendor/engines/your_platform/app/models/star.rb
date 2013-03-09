class Star < ActiveRecord::Base
  attr_accessible :starrable_id, :starrable_type, :user_id, :user, :starrable

  belongs_to :starrable, polymorphic: true
  belongs_to :user

  # Starring and Un-starring objects
  # ==========================================================================================
  #
  # Make a user star an object by calling:
  #
  #     Star.star( user: current_user, starrable: object_to_star )
  #     Star.create( user: current_user, starrable: object_to_star )
  #
  # Make a user unstar an object by calling: 
  #
  #     Star.unstar( user: current_user, starrable: object_to_unstar )
  #     Star.find_by_user_and_starrable( current_user, object_to_unstar ).destroy
  #
  def self.star( params )
    self.create( params )
  end
  def self.unstar( params )
    self.find_by_user_and_starrable( params[ :user ], params[ :starrable ] ).destroy
  end


  # Did a user star an object?
  # ==========================================================================================
  #
  # This method finds out whether a user did star a starrable object.
  # This is equivalent to a star record existing belonging to this user and this
  # object.
  # 
  #     Star.user_starred_object? user, group        # => true/false
  #     Star.starred? user: user, starrable: group   # => true/false
  #
  def self.user_starred_object?( user, starrable )
    self.find_by_user_and_starrable( user, starrable ).present?
  end
  def starred?( params )
    self.user_starred_object? params[ :user ], params[ :starrable ]
  end


  # Finder Methods
  # ==========================================================================================

  def self.find_by_user_and_starrable( user, starrable )
    self.find_all_by_user( user ).find_all_by_starrable( starrable ).first
  end

  def self.find_all_by_user( user )
    self.where( :user_id => user.id )
  end

  def self.find_all_by_starrable( starrable )
    self.where( :starrable_type => starrable.class.name, :starrable_id => starrable.id )
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
                       :starrable => {
                         :methods => [ :title, :url ]
                       }
                     }
                   } )
    super( options )
  end

end


module ActiveRecord
  class Base
    
    include Rails.application.routes.url_helpers
    include ActionDispatch::Routing::UrlFor

    def default_url_options
      { host: "localhost:3000", :only_path => true }
    end

    def url
      url_for self
    end

    def serialize_hash( options = {} )
      super options.merge( :methods => :url )
    end

  end
end
