#
# This file contains the code to import users from the deleted-string csv export.
# Import users like this:
#
#   require 'tasks/user_import'
#   importer = UserImporter.new( file_name: "path/to/csv/file" )
#   importer.import( filter: { "uid" => "W51061" } )
#   User.all  # will list all users
#

require 'importers/importer'

class UserImporter < Importer

  # Import users like this:
  #
  #   UserImport.import( file_name: "path/to/csv/file", filter: { "uid" => "W51061" } )
  #
  def import( args = {} )
    self.file_name = args[:file_name] if args[:file_name]
    self.filter = args[:filter] if args[:filter]
    import_users
  end

  private

  def import_users
    counter = 0
    @warnings = []
    @errors = []
    import_file = ImportFile.new( file_name: @file_name, data_class_name: "UserData" )
    import_file.each_row do |user_data|
      if user_data.match? @filter 
        @debug_user_data=user_data # TODO :REMOVE!
        unless user_data.user_alredy_exists? || user_data.email_already_exists?
          print ".".green
          counter += 1
          user = User.create( user_data.attributes )
          user.import_profile_fields( user_data.profile_fields_hash )
        else
          if user_data.user_alredy_exists?
            @warnings << { message: "user already exists", user_data: user_data }
            print ".".yellow
          end
          if user_data.email_already_exists?
            @errors << { message: "email already exists", user_data: user_data }
            print ".".red
          end
        end
      end
    end
    print "\n"
    print "#{counter} users have been imported.\n".green
  end
end


class UserData

  def initialize( data_hash )
    @data_hash = data_hash
  end

  def data_hash_value( key )
    val = @data_hash[ key ] 
    val ||= @data_hash[ key.to_s ]
  end

  def d( key )
    data_hash_value(key)
  end

  # The filter is a Hash the data_hash is compared against.
  # The method returns true if the data_hash contains the information
  # given in the filter hash.
  #
  # Example:
  #
  #   filter = { "uid" => "1234" }
  #
  def match?( filter )
    return true if filter.nil?
    return ( @data_hash.slice( *filter.keys ) == filter )
  end

  def user_alredy_exists?
    user = User.where( first_name: self.first_name, last_name: self.last_name ).limit(1).includes( :profile_fields ).first
    return false unless user
    return false unless user.date_of_birth == self.date_of_birth
    return true
  end

  def email_already_exists?
    return false if not self.email.present?
    return true if User.find_all_by_email( self.email ).count > 0 if self.email
  end

  def attributes
    {
      first_name:         self.first_name,
      last_name:          self.last_name,
      date_of_birth:      self.date_of_birth,
    }
  end

  def profile_fields_hash
    {
      'E-Mail' => { value: self.email, type: 'Email' },
      'Heimatanschrift' => { value: self.home_address, type: 'Address' }
    }
  end

  def home_address
    "#{d(:homePostalAddress)}\n" +
      "#{d(:epdpersonalpostalcode)} #{d(:epdpersonalcity)}\n" +
      "#{d(:epdcountry)}"
  end

  def professional_address
    "#{d(:epdprofaddress)}\n" +
      "#{d(:epdprofpostalcode)} #{d(:epdprofcity)}\n" +
      "#{d(:epdprofcountry)}"
  end

  def first_name
    d(:givenName)
  end
  def last_name
    d(:sn)
  end

  def email
    d(:mail)
  end

  def date_of_birth
    begin
      d(:epdbirthdate).to_date
    rescue # wrong date format
      return nil
    end
  end

  def alias
    d(:epdalias)
  end
  def username
    self.alias
  end

  def academic_title
    d(:epdeduacademictitle)
  end

  def w_nummer
    d(:employeeNumber)
  end

  # status returns one of these strings:
  #   "Aktiver", "Philister", "Ehemaliger"
  #
  def status
    d(:epdorgstatusofperson)
  end

end



module UserImportMethods

  # The profile_fields_hash should look like this:
  #
  #   profile_fields_hash = { 'Work Address': { value: "my work address...", type: "Address" },
  #                           'Work Phone': { value: "1234", type: "Phone" },
  #                           ... }
  #
  def import_profile_fields( profile_fields_hash )
    profile_fields_hash.each do |label, attrs|
      attrs[ :label ] = label
      profile_field = self.profile_fields.create
      profile_field.import_attributes( attrs )
    end
  end

end

User.send( :include, UserImportMethods )

module ProfileFieldImportMethods

  # The attr_hash to import should look like this:
  #
  #   attr_hash = { label: ..., value: ..., type: ... }
  #
  # Types are:
  #
  #   Address, Email, Phone, Custom
  #
  def import_attributes( attr_hash )
    if attr_hash && attr_hash.kind_of?( Hash ) &&
        attr_hash[:label].present? && attr_hash[:value].present? && attr_hash[:type].present?

      unless attr_hash[:type].start_with? "ProfileFieldTypes::"
        attr_hash[:type] = "ProfileFieldTypes::#{attr_hash[:type]}"
      end

      self.update_attributes( attr_hash )
    end
  end

end

ProfileField.send( :include, ProfileFieldImportMethods )

