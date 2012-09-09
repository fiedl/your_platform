# -*- coding: utf-8 -*-
class AddGroupFlagsToExistingSpecialGroups < ActiveRecord::Migration
  def up

    # Refactorization Matrix
    # 
    # (1) Rake Tasks
    # (2) Bang Methods in Group Model W
    # (3) Bang Methods in Grouo Model Y
    # (4) Migration (this file)
    # (5) Group.set_flags_based_on_group_name
    # (6) Locales
    #
    #                      |  (1)   (2)   (3)   (4)   (5)   (6)
    # everyone             |   ✓     ✓     ✓     ✓     /     ✓
    # officers_parent      |   ✓     ✓     ✓     ✓     ✓     ✓
    # corporations_parent  |   ✓     ✓     ✓     ✓     /     ✓
    # bvs_parent           |   ✓     ✓     ✓     ✓     /     ✓
    # 
    
    # Everyone Group
    Group.find_all_by_name( "Jeder" ).each do |everyone_group|
      everyone_group.add_flag( :everyone )
    end

    # Officers Parent Groups
    Group.find_all_by_name( "Amtsträger" ).each do |officers_parent|
      officers_parent.add_flag( :officers_parent )
    end

    # Corporations Parent Group
    Group.find_all_by_name( "Wingolf am Hochschulort" ).each do |corporations_parent|
      corporations_parent.add_flag( :corporations_parent )
    end

    # Bvs Parent Group
    Group.find_all_by_name( "Bezirksverbände" ).each do |bvs_parent|
      bvs_parent.add_flag( :bvs_parent )
    end

  end
end
