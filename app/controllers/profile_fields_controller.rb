class ProfileFieldsController < ApplicationController

  prepend_before_filter :load_profileable, :only => :create
  load_and_authorize_resource
  respond_to :json, :js

  def create
    type = secure_profile_field_type || 'ProfileFieldTypes::Custom'
    @profile_field = @profile_field.becomes(type.constantize)
    @profile_field.profileable = @profileable
    @profile_field.label = params[:label] if params[:label].present?
    @profile_field.value = "—"
    @profile_field.save if @profile_field.changed?
    respond_to do |format|
      format.js
    end
  end

  def update
    @profile_field = ProfileField.find(params[:id])
    if @profile_field.type.in? ["ProfileFieldTypes::Address",			"ProfileFieldTypes::AcademicDegree",	"ProfileFieldTypes::Klammerung", "ProfileFieldTypes::BankAccount",		"ProfileFieldTypes::Competence", 			"ProfileFieldTypes::Custom", 			"ProfileFieldTypes::Date", "ProfileFieldTypes::Email",					"ProfileFieldTypes::Description", 		"ProfileFieldTypes::Employment", "ProfileFieldTypes::General", 			"ProfileFieldTypes::Homepage",				"ProfileFieldTypes::NameSurrounding", "ProfileFieldTypes::Organization", 	"ProfileFieldTypes::Phone",						"ProfileFieldTypes::ProfessionalCategory", "ProfileFieldTypes::Study"]
      profile_field_class = @profile_field.type.constantize
    else
      raise "security interrupt: '#{@profile_field.type}' is no permitted profileable object type."
    end
    @profile_field = @profile_field.becomes( profile_field_class )
    updated = @profile_field.update_attributes(params[:profile_field])
    respond_with_bip @profile_field
  end
  
  def destroy
    respond_with @profile_field.destroy
  end
  
  private
  
  def load_profileable
    if params[ :section ].present?
      @section = params[ :section ]
    end
    if params[ :profileable_type ].present? && params[ :profileable_id ].present?
      @profileable = secure_profileable_type.constantize.find( params[ :profileable_id ] )
    elsif params[ :profileable_type ].blank? and params[ :profileable_id ].blank?
      raise "Profileable type and id are missing!"
    elsif params[ :profileable_type ].blank?
      raise "Profileable type is missing!"
    else
      raise "Profileable id is missing!"
    end
  end
  
  def secure_profileable_type
    if not params[:profileable_type].in? ["User", "Group"]
      raise "security interrupt: '#{params[:profileable_type]}' is no permitted profileable object type."
    end
    params[:profileable_type]
  end
  
  def secure_profile_field_type
    if not params[:profile_field][:type].in? ([''] + ProfileField.possible_types)
      raise "security interrupt: '#{params[:profile_field][:type]}' is not a permitted profile field type."
    end
    params[:profile_field][:type]
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
