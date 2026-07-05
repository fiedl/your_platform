class ModifyProfileFieldTypeColumn < ActiveRecord::Migration[4.2]
  def up
    # This is not needed for fresh installs anymore.
    #
    # # ProfileField.all.each do |pf|
    # #   pf.update_attributes( type: "ProfileFieldTypes::#{pf.type}" ) if not pf.type.include?( "::" ) if pf.type
    # # end
  end

  def down
    # This is not needed for fresh installs anymore.
    #
    # # ProfileField.all.each do |pf|
    # #   pf.update_attributes( type: pf.type.gsub( "ProfileFieldTypes::", "" ) ) if pf.type
    # # end
  end
end
