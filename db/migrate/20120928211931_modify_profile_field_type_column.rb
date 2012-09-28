class ModifyProfileFieldTypeColumn < ActiveRecord::Migration
  def up
    ProfileField.all.each do |pf|
      pf.update_attributes( type: "ProfileFieldTypes::#{pf.type}" ) if not pf.type.include?( "::" ) if pf.type
    end
  end

  def down
    ProfileField.all.each do |pf|
      pf.update_attributes( type: pf.type.gsub( "ProfileFieldTypes::", "" ) ) if pf.type
    end
  end
end
