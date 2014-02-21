module ProfileFieldTypes

  # Bank Account Information
  # 
  class BankAccount < ProfileField
    def self.model_name; ProfileField.model_name; end

    has_child_profile_fields( :account_holder, :account_number, :bank_code,
                              :credit_institution, :iban, :bic )
  end
  
end