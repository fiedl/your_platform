require File.join(Rails.root, 'app/models/profile_field')

class ProfileField
  
  # The attr_hash to import should look like this:
  #
  #   attr_hash = { label: ..., value: ..., type: ... }
  #
  # Types are:
  #
  #   Address, Email, Phone, Custom
  #
  def import_attributes( attr_hash )
    if attr_hash && attr_hash.kind_of?( Hash ) &&
        attr_hash[:label].present? && attr_hash[:type].present? &&
        attr_hash.keys.count > 2 # label, type, and some form of value

      unless attr_hash[:type].start_with? "ProfileFieldTypes::"
        attr_hash[:type] = "ProfileFieldTypes::#{attr_hash[:type]}"
      end

      self.update_attributes( type: attr_hash[:type] )
      self.save

      # This is needed in order to have access to the methods
      # that depend on the type set above.
      #
      reloaded_self = ProfileField.find(self.id)

      attr_hash.each do |key,value|
        reloaded_self.send("#{key}=", value)
      end
      reloaded_self.save

    end
  end
    
end