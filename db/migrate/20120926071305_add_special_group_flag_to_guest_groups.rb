# -*- coding: utf-8 -*- 
class AddSpecialGroupFlagToGuestGroups < ActiveRecord::Migration
  def up

    # Guests Parent
    Group.find_all_by_name( "Gäste" ).each do |guests_parent|
      guests_parent.add_flag( :guests_parent )
    end

  end
end
