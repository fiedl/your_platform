class MapController < ApplicationController

  def show
    @address_fields = find_address_fields
  end

  private

  def find_address_fields
    group = Group.find(params[:group_id]) if params[:group_id]
    if group
      user_ids = group.descendant_users.pluck(:id)
      address_fields = ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "User", profileable_id: user_ids )
      return address_fields
    end
  end

end
