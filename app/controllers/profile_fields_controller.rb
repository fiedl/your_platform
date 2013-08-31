class ProfileFieldsController < ApplicationController

  load_and_authorize_resource
  before_filter :load_profileable
  respond_to :json, :js

  def create
    type = params[:profile_field][:type] || ProfileFieldTypes::Custom.name
    @profile_field = @profile_field.becomes(type.constantize)
    @profile_field.profileable = @profileable
    @profile_field.label = params[:label] if params[:label].present?
    @profile_field.save
    respond_to do |format|
      format.js
    end
  end
  
  def update
    respond_with @profile_field.update_attributes(params[:profile_field])
  end
  
  def destroy
    respond_with @profile_field.destroy
  end
  
  private
  
  def load_profileable
    if params[ :profileable_type ].present? && params[ :profileable_id ].present?
      @profileable = params[ :profileable_type ].constantize.find( params[ :profileable_id ] )
    end
  end

#   before_filter        :find_profileable
# #  before_filter        :load_profile_field_as_instance_variable
# #  respond_to           :html, :json
#   respond_to           :json
#   layout               false
# 
#   def index
#     @profile_fields = @profileable.profile_fields if @profileable
#     @profile_fields ||= ProfileField.find_all_by_parent_id( params[ :parent_id ] ) if params[ :parent_id ]
#     respond_with @profile_fields.to_json( include: [ :children ] )
#   end
# 
#   def show
#     respond_with ProfileField.find( params[ :id ] )
#   end
# 
# 
#   def update
#     respond_with ProfileField.update( params[ :id ], params[ :profile_field ] )
# #    @profile_field.update_attributes( params[ :profile_field ] )
# #    respond_to do |format|
# #      format.json { respond_with_bip( @profile_field ) }
# #    end
# #    #respond_with @profile_field
# #    #render action: 'show'
#   end
# 
#   def destroy
#     # For compatibility reasons, this is messy, now:
#     # This would be the REST response, compatible to angular js:
# #    respond_with ProfileField.destroy( params[ :id ] )  
# 
#     # And this is needed for the current interface, because then a js template
#     # is rendered and sent back to the client (in order to hide the deleted
#     # elements).
#     # @profile_field.destroy
# 
#     # And this would be the HTML response:
# #    redirect_to profileable #controller: 'users', action: 'show', id: user_id
#   end
# 
#   private
# 
#   def find_profileable
#     if params[ :profileable_type ].present? && params[ :profileable_id ].present?
#       @profileable = params[ :profileable_type ].constantize.find( params[ :profileable_id ] )
#     end
#   end
# 
# #
# #  def load_profile_field_as_instance_variable
# #    id = params[ :id ]
# #    if id
# #      @profile_field = ProfileField.find_by_id( id )
# #    else
# #      @profile_field = ProfileField.new
# #    end
# #  end

end
