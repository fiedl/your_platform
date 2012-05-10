class ProfileFieldsController < ApplicationController

  before_filter        :load_profile_field_as_instance_variable
  layout               false

  def show
  end

  def edit
  end

  def update
    @profile_field.update_attributes( params[ :profile_field ] )
    render action: 'show'
  end

  def destroy
    profileable = @profile_field.profileable
    @profile_field.destroy
    redirect_to profileable #controller: 'users', action: 'show', id: user_id
  end

  private

  def load_profile_field_as_instance_variable
    id = params[ :id ]
    if id
      @profile_field = ProfileField.find_by_id( id )
    else
      @profile_field = ProfileField.new
    end
  end

end
