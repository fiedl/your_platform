class ProfileFieldsController < ApplicationController

  before_filter        :find_profileable
#  before_filter        :load_profile_field_as_instance_variable
#  respond_to           :html, :json
  respond_to           :json
  layout               false

  def index
    @profile_fields = @profileable.profile_fields if @profileable
    respond_with @profile_fields
  end

  def show
    respond_with ProfileField.find( params[ :id ] )
  end

  def edit
  end

  def create
    respond_with @profileable.profile_fields.create( params[ :profile_field ] ) if @profileable
  end

  def update
    respond_with ProfileField.update( params[ :id ], params[ :profile_field ] )
#    @profile_field.update_attributes( params[ :profile_field ] )
#    respond_to do |format|
#      format.json { respond_with_bip( @profile_field ) }
#    end
#    #respond_with @profile_field
#    #render action: 'show'
  end

  def destroy
    respond_with ProfileField.destroy( params[ :id ] )
#    profileable = @profile_field.profileable
#    @profile_field.destroy
#    redirect_to profileable #controller: 'users', action: 'show', id: user_id
  end

  private

  def find_profileable
    if params[ :profileable_type ] && params[ :profileable_id ]
      @profileable = params[ :profileable_type ].constantize.find( params[ :profileable_id ] )
    end
  end

#
#  def load_profile_field_as_instance_variable
#    id = params[ :id ]
#    if id
#      @profile_field = ProfileField.find_by_id( id )
#    else
#      @profile_field = ProfileField.new
#    end
#  end

end
