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
          import_group_profile_info bv, row.to_hash
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

  def import_group_profile_info( bv, infos )
    info_mapping = [
                    { import_field: 'description', label: "Beschreibung", type: "Description" },
                    { import_field: 'mail',        label: "E-Mail",       type: "Email" }
                   ]
    info_mapping.each do |m|
      profile_field_hash = {}
      profile_field_hash[ :value ] = infos[ m[ :import_field ] ]
      profile_field_hash.merge! m.reject { |key| not ProfileField.attr_accessible[:default].include? key }
      p bv.profile_fields.new( profile_field_hash )
    end

  end

end
