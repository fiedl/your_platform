# -*- coding: utf-8 -*-
# Data Migration Task
# Execute by typing  'rake data_migration:all'.
# SF 2012-05-08

namespace :data_migration do


  desc "Import BV information"
  task import_bv_information: :environment do
    p "Task: Import BV information"
    csv_rows( "deleted-string_data/groups.csv" ) do |row|
      if row[ 'cn' ]
        if row[ 'cn' ].include? "BV "
          bv = Bv.by_token row[ 'cn' ]
          infos = row.to_hash
          import_group_profile_info bv, infos
          import_bank_account bv, infos
        end
      end
    end
  end

  desc "Run data migration tasks."
  task :all => [
                :import_bv_information
               ]

  def csv_rows( file_title, &block )
    require 'csv'
    file_name = File.join( Rails.root, "import", file_title )
    if File.exists? file_name
      counter = 0
      CSV.foreach file_name, headers: true, col_sep: ';' do |row|
        result = yield row
        counter += 1 unless result.nil?
      end
      p "Data migration entries processed: " + counter.to_s
    end
  end

  def import_group_profile_info( profileable, infos )
    info_mapping = [
                    { import_field: 'description', label: "Hinweis",      type: "Description" },
                    { import_field: 'mail',        label: "E-Mail",       type: "Email" }
                   ]
    info_mapping.each do |m|
      add_profile_field_to profileable.profile_fields, infos, m
    end

  end

  def import_bank_account( profileable, infos )
    account = profileable.profile_fields.create(  label: "Bankverbindung",          type: "BankAccount" )
    add_profile_field_to account.children, infos, label: "Kontoinhaber",    import_field: 'epdbankaccountowner'
    add_profile_field_to account.children, infos, label: "Konto-Nr.",       import_field: 'epdbankaccountnr'
    add_profile_field_to account.children, infos, label: "BLZ",             import_field: 'epdbankid'
    add_profile_field_to account.children, infos, label: "Kreditinstitut",  import_field: 'epdbankinstitution'
    add_profile_field_to account.children, infos, label: "IBAN",            import_field: 'epdbankiban' 
    add_profile_field_to account.children, infos, label: "BIC",             import_field: 'epdbankswiftcode'
  end

  def add_profile_field_to( profile_fields, infos, new_field_hash )
    new_field_hash[ :value ] = infos[ new_field_hash[ :import_field ] ]
    new_field_hash.reject! { |key| not ProfileField.attr_accessible[:default].include? key }
    profile_fields.create( new_field_hash )
  end

end
