# -*- coding: utf-8 -*-
module ProfileFieldMixins::HasChildProfileFieldAccessors

  # This creates an easier way to access a composed ProfileField's child field
  # values. Instead of calling 
  #
  #    bank_account.children.where( :label => :account_number ).first.value
  #    bank_account.children.where( :label => :account_number ).first.value = "12345"
  #
  # you may call
  # 
  #    bank_account.account_number
  #    bank_account.account_number = "12345"
  #
  # after telling the profile_field to create these accessors:
  #
  #    class BankAccount < ProfileField
  #      ...
  #      has_child_profile_field_accessors :account_holder, :account_number, ...
  #      ...
  #    end
  # 
  def has_child_profile_field_accessors( *accessors )

    after_save :save_child_profile_field_accessors

    include HasChildProfileFieldAccessorsInstanceMethods

    accessors.each do |accessor|

      self.class_eval <<-EOL

          def #{accessor}
            self.get_field( :#{accessor} )
          end

          def #{accessor}=( new_value )
            self.set_field( :#{accessor}, new_value )
          end

      EOL

    end
  end

  module HasChildProfileFieldAccessorsInstanceMethods

    def save_child_profile_field_accessors
      if @children
        @children.each do |key, child_profile_field|
          child_profile_field.save
        end
      end
    end
    private :save_child_profile_field_accessors

    def get_field( accessor )
      @children ||= {}
      @children[ accessor ] ||= self.children.where( :label => accessor ).first
      @children[ accessor ].value
    end

    def set_field( accessor, value )
      @children ||= {}
      @children[ accessor ] ||= self.children.where( :label => accessor ).first
      @children[ accessor ].value = value
    end

  end

end
