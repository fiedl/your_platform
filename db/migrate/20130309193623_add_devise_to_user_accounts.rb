class AddDeviseToUserAccounts < ActiveRecord::Migration
  def self.up
    change_table(:user_accounts) do |t|
      ## Database authenticatable
      #t.string :email,              :null => false, :default => ""
      if Rails.version.starts_with?("3")
        t.string :encrypted_password, :null => false, :default => ""
      else
        # https://github.com/fiedl/wingolfsplattform/commit/01f7d3182387aaca99564216661bb7b222fee084#diff-e7267e28ca9cf34b8ba67e6b088344caR5
        # http://stackoverflow.com/a/12990129/2066546
        t.change :encrypted_password, :string, null: false, default: ""
      end

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Token authenticatable
      # t.string :authentication_token


      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps

      t.remove :password_digest
    end

    #add_index :user_accounts, :email,                :unique => true
    add_index :user_accounts, :reset_password_token, :unique => true
    # add_index :user_accounts, :confirmation_token,   :unique => true
    # add_index :user_accounts, :unlock_token,         :unique => true
    # add_index :user_accounts, :authentication_token, :unique => true

  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    remove_column :user_accounts, :encrypted_password

    ## Recoverable
    remove_column :user_accounts, :reset_password_token
    remove_column :user_accounts, :reset_password_sent_at

    ## Rememberable
    remove_column :user_accounts, :remember_created_at

    ## Trackable
    remove_column :user_accounts, :sign_in_count
    remove_column :user_accounts, :current_sign_in_at
    remove_column :user_accounts, :last_sign_in_at
    remove_column :user_accounts, :current_sign_in_ip
    remove_column :user_accounts, :last_sign_in_ip

    add_column :user_accounts, :password_digest, :string
  end
end
