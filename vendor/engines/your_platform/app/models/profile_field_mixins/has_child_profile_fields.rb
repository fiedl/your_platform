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

    before_save :build_child_fields_if_absent
    after_save :save_child_profile_fields

    include HasChildProfileFieldsInstanceMethods

    self.class_eval <<-EOL

      def labels
        #{labels}
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

    def find_child_by_label(label)
      # we have to use 'select' here instead of 'where', because this needs
      # to work before the records are saved. But this should not be a problem,
      # since there are only a couple of child fields.
      #
      self.children.select { |child| child.label.to_s == label.to_s }.first
    end
    def find_or_build_child_by_label(label)
      find_child_by_label(label) || children.build( label: label )
    end

    def build_child_fields_if_absent
      if self.children.count == 0
        build_child_fields self.labels
      end
    end

    def build_child_fields( labels )
      if self.parent == nil # do it only for the parent, not the children as well
        labels.each do |label|
          children.build( label: label ) unless find_child_by_label(label)
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
      find_child_by_label(accessor).value
    end

    def set_field( accessor, value )
      build_child_fields_if_absent
      find_child_by_label(accessor).value = value
    end

  end

end
