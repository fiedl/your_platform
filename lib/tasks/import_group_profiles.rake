require 'importers/models/log'
require 'colored'

namespace :import do
  
  $groups_import_file = "import/netenv_data/Groups_production_2012-01-17.csv" 
  
  desc "Import group profiles from netenv system."
  task :group_profiles => [
    'environment',
    'bootstrap:all',
    'group_profiles:print_info',
    'group_profiles:import_bv_information',
    'group_profiles:import_wah_information',
    'group_profiles:import_aktivitas_information',
    'group_profiles:import_philisterschaft_information',
    'group_profiles:import_hausverein_information'
  ]
  
  namespace :group_profiles do
    
    task :print_info do
      Log.new.section "Import group profiles."
    end
      

    desc "Import BV information"
    task import_bv_information: :environment do
      p "Task: Import BV information"
      csv_rows($groups_import_file) do |row|
        if row[ 'cn' ]
          if row[ 'cn' ].include? "BV "
            bv = Bv.find_by_token row[ 'cn' ]
            infos = row.to_hash
            import_group_profile_info bv, infos
            import_bank_account bv, infos
          end
        end
      end
    end
    
    desc "Import Wah information"
    task import_wah_information: :environment do
      p "Task: Import Wah (Wingolf am Hochschulort) information"
      csv_rows($groups_import_file) do |row|
        if row[ 'cn' ]
          if row[ 'cn' ].include? "WV "
            if row[ 'dn' ].include? "o=Verbindungen"
              token = row[ 'cn' ][3..-1] # "Ef" aus "WV Ef"
              wah = Corporation.find_by_token( token ) # Wingolf-am-Hochschulort-Gruppe
              infos = row.to_hash
              import_address wah, infos
              import_group_profile_info wah, infos
            end
          end
        end
      end
    end
    
    desc "Import Aktivitas information"
    task import_aktivitas_information: :environment do
      p "Task: Import Aktivitas information"
      csv_rows($groups_import_file) do |row|
        if row[ 'cn' ]
          if row[ 'cn' ].include? "WV " 
            if row[ 'dn' ].include? "o=Verbindungen"
              token = row[ 'cn' ][3..-1] # "Ef" aus "WV Ef"
              aktivitas = Corporation.find_by_token( token ).aktivitas
              infos = row.to_hash
              aktivitas.token = infos[ 'cn' ]
              aktivitas.save
              import_bank_account( aktivitas, infos )
            end
          end
        end
      end
    end
    
    desc "Import Philisterschaft information"
    task import_philisterschaft_information: :environment do
      p "Task: Import Philisterschaft information"
      csv_rows($groups_import_file) do |row|
        if row[ 'cn' ]
          if row[ 'cn' ].include? "PhV " 
            if row[ 'dn' ].include? "o=Philister"
              if not row[ 'cn' ].include? "bandphilister" 
                token = row[ 'cn' ][4..-1] # "Ef" aus "PhV Ef"
                philisterschaft = Corporation.find_by_token( token ).philisterschaft
                infos = row.to_hash
                philisterschaft.extensive_name = infos[ 'ou' ]
                philisterschaft.token = infos[ 'cn' ]
                philisterschaft.save            
                import_group_profile_info philisterschaft, infos
                import_bank_account( philisterschaft, infos )
              end
            end
          end
        end
      end
    end
    
    desc "Import Hausverein information"
    task import_hausverein_information: :environment do 
      p "Task: Import Hausverein information"
      csv_rows($groups_import_file) do |row|
        if row[ 'cn' ]
          if row[ 'cn' ].include? "PhV " 
            if row[ 'dn' ].include? "o=Philister"
              if not row[ 'cn' ].include? "bandphilister" 
                token = row[ 'cn' ][4..-1] # "Ef" aus "PhV Ef"
                hausverein = Corporation.find_by_token( token ).hausverein
                if hausverein
                  infos = row.to_hash
                  hausverein.extensive_name = infos[ 'epdwingolfphhvname' ]
                  hausverein.save
                  import_bank_account( hausverein, infos, "epdwingolfphhv" )
                end
              end
            end
          end
        end
      end
    end
    
    
    
    def csv_rows( file_title, &block )
      require 'csv'
      file_name = File.join( Rails.root, file_title )
      if File.exists? file_name
        counter = 0
        CSV.foreach file_name, headers: true, col_sep: ';' do |row|
          result = yield row
          counter += 1 unless result.nil?
        end
        p "Data migration entries processed: " + counter.to_s
      else
        print "MISSING FILE: #{file_name}\n".red
      end
    end
    
    def import_group_profile_info( profileable, infos )
      info_mapping = [
                      { import_field: 'mail',                       label: "E-Mail",       type: "ProfileFieldTypes::Email" },
                      { import_field: 'telephoneNumber',            label: "Telefon",      type: "ProfileFieldTypes::Phone" },
                      { import_field: 'facsimileTelephoneNumber',   label: "Fax",          type: "ProfileFieldTypes::Phone" },
                      { import_field: 'seeAlso',                    label: "Internet",     type: "ProfileFieldTypes::Homepage" },
                      { import_field: 'description',                label: "Hinweis",      type: "ProfileFieldTypes::Description" },
                      { import_field: 'epdwingolfsubcomwahlspruch', label: "Wahlspruch",   type: "ProfileFieldTypes::Description" },
                      { import_field: 'epdwingolfsubcomgegruendet', label: "Informationen zur Gründung", type: "ProfileFieldTypes::Description" },
                      { import_field: 'epdwingolfsubcomband',       label: "Band",         type: "ProfileFieldTypes::Description" },
                      { import_field: 'epdwingolfsubcommuetze',     label: "Mütze",        type: "ProfileFieldTypes::Description" },
                      { import_field: 'epdwingolfsubcomcerevis',    label: "Cerevis",      type: "ProfileFieldTypes::Description" },
                      { import_field: 'epdwingolfsubcomtoennchen',  label: "Tönnchen",     type: "ProfileFieldTypes::Description" },
                      { import_field: 'epdwingolfsubcomtradition',  label: "Tradition",    type: "ProfileFieldTypes::Description" },
                      { import_field: 'epdwingolfsubcompostille',   label: "Verbindungszeitschrift", type: "ProfileFieldTypes::Description" },
                     ]
      info_mapping.each do |m|
        add_profile_field_to profileable.profile_fields, infos, m
      end
      profileable.internal_token = infos[ 'initials' ] if infos[ 'initials' ]
      profileable.save
    end
    
    def import_bank_account( profileable, infos, prefix = "epd" )
      account = add_profile_field_to profileable.profile_fields, 
                                             infos, label: "Bankverbindung",          type: "ProfileFieldTypes::BankAccount",               force: true 
      #   account = profileable.profile_fields.create(  label: "Bankverbindung",          type: "BankAccount" )
      add_profile_field_to account.children, infos, label: "Kontoinhaber",    import_field: prefix + 'bankaccountowner', force: true
      add_profile_field_to account.children, infos, label: "Konto-Nr.",       import_field: prefix + 'bankaccountnr',    force: true
      add_profile_field_to account.children, infos, label: "BLZ",             import_field: prefix + 'bankid',           force: true
      add_profile_field_to account.children, infos, label: "Kreditinstitut",  import_field: prefix + 'bankinstitution',  force: true
      add_profile_field_to account.children, infos, label: "IBAN",            import_field: prefix + 'bankiban',         force: true 
      add_profile_field_to account.children, infos, label: "BIC",             import_field: prefix + 'bankswiftcode',    force: true
    end
    
    def import_address( profileable, infos, prefix = "" )
      plz = infos[ prefix + 'postalCode' ]
      street = infos[ prefix + 'postalAddress' ]
      country = infos[ prefix + 'epdcountry' ]
      city = infos[ prefix + 'l' ]
      address = "#{street}, #{plz} #{city}, #{country}"
      add_profile_field_to( profileable.profile_fields, infos, 
                            label: "Anschrift", type: "ProfileFieldTypes::Address",
                            value: address,
                            force: true )
    end 
    
    def add_profile_field_to( profile_fields, infos, new_field_hash )
      force = new_field_hash[ :force ]
      new_field_hash[ :value ] = infos[ new_field_hash[ :import_field ] ] if new_field_hash[ :import_field ]
      new_field_hash.reject! { |key| not ProfileField.attr_accessible[:default].include? key }
      if new_field_hash[ :value ] or force
        profile_fields.create( new_field_hash )
#        pf = profile_fields.new( new_field_hash ) # FOR DEBUG
#        p pf                                      # 
#        pf                                        #
      end
    end

  end
end

