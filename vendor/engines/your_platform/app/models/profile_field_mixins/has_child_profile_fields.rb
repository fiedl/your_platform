# -*- coding: utf-8 -*-
module ProfileFieldMixins::HasChildProfileFields

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
  #      has_child_profile_fields :account_holder, :account_number, ...
  #      ...
  #    end
  # 
  # Furthermore, this method modifies the intializer to build the child fields
  # on build of the main profile_field.
  #
  def has_child_profile_fields( *labels )

    after_save :save_child_profile_fields

    include HasChildProfileFieldsInstanceMethods

    self.class_eval <<-EOL

      def initialize( *attrs )
        super( *attrs )
        self.build_child_fields( #{labels} )
      end

    EOL


    labels.each do |accessor|

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

  module HasChildProfileFieldsInstanceMethods

    def build_child_fields( labels )
      if self.parent == nil # do it only for the parent, not the children as well
        labels.each do |label|
          self.children.build( label: label )
        end
      end
    end

    def save_child_profile_fields
      if @children
        @children.each do |key, child_profile_field|
          child_profile_field.save
        end
      end
    end
    private :save_child_profile_fields

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
