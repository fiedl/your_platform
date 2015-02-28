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
  def has_child_profile_fields( *keys )

    before_save :build_child_fields_if_absent
    after_save :save_child_profile_fields
    
    attr_accessible *keys

    include HasChildProfileFieldsInstanceMethods

    self.class_eval <<-EOL

      def keys
        #{keys}
      end

    EOL


    keys.each do |accessor|

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

    def find_child_by_key(key)
      # we have to use 'select' here instead of 'where', because this needs
      # to work before the records are saved. But this should not be a problem,
      # since there are only a couple of child fields.
      #
      self.children.select { |child| child.key.to_s == key.to_s }.first
    end
    def find_or_build_child_by_key(key)
      find_child_by_key(key) || build_child(key)
    end

    def build_child_fields_if_absent
      if self.children_count == 0
        build_child_fields self.keys
      end
    end

    def build_child_fields( keys )
      if self.parent == nil # do it only for the parent, not the children as well
        keys.each do |key|
          build_child(key) unless find_child_by_key(key)
        end
      end
    end

    # This method saves the child profile fields. 
    # This is necessary, since the acts_as_tree gem does not provide the
    # autosave option for the association.
    #
    def save_child_profile_fields
      children.each do |child_field|
        child_field.save
      end
    end
    private :save_child_profile_fields

    def get_field( accessor )
      find_child_by_key(accessor).value if find_child_by_key(accessor)
    end

    def set_field( accessor, value )
      build_child_fields_if_absent
      find_child_by_key(accessor).value = value
    end

    def build_child( key )
      children.build( label: key )
    end

  end

end
