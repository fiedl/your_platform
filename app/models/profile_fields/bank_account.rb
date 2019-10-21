module ProfileFields

  # Bank Account Information
  #
  class BankAccount < ProfileField
    def self.model_name; ProfileField.model_name; end

    has_child_profile_fields( :account_holder, :account_number, :bank_code,
                              :credit_institution, :iban, :bic )

    def composed_value
      #if iban
      #  field_keys = [:account_holder, :iban, :bic, :credit_institution]
      #else
      #  field_keys = [:account_holder, :account_number, :bank_code, :credit_institution]
      #end
      #(field_keys.collect { |field_key|
      #  field = find_child_by_key field_key
      #  field.label + ": " + field.value if field && field.value.present?
      #} - [nil]).join("\n")
      (children.collect { |child|
        child.label + ": " + child.value if child.value.present?
      } - [nil]).join("\n")
    end

    def to_s
      composed_value
    end
  end

end