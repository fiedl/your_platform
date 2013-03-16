require 'importers/importer'

#
# This file contains the code to import users from the deleted-string csv export.
# Import users like this:
#
#   require 'importers/user_import'
#   importer = UserImporter.new( file_name: "path/to/csv/file", filter: { "uid" => "W51061" },
#                                update_policy: :update )
#   importer.import
#   User.all  # will list all users
#
class UserImporter < Importer

  def import
    import_file = ImportFile.new( file_name: @file_name, data_class_name: "UserData" )
    import_file.each_row do |user_data|
      if user_data.match? @filter 
        handle_existing(user_data) do |user|
          handle_existing_email(user_data) do |email_warning|
            user.update_attributes( user_data.attributes )
            user.import_profile_fields( user_data.profile_fields_hash )
            progress.log_success unless email_warning
          end
        end
      end
    end
    progress.print_status_report
  end

  private

  def handle_existing( data, &block )
    if data.user_already_exists?
      if update_policy == :ignore
        progress.log_ignore( { message: "user already exists", user_uid: data.uid, name: data.name } ) 
        user = nil
      end
      if update_policy == :replace
        data.existing_user.destroy 
        user = User.new 
      end
      if update_policy == :update
        user = data.existing_user
      end
      yield( user ) if update_policy == :update || update_policy == :replace
    else
      yield( User.new )
    end
  end

  def handle_existing_email( data, &block )
    if data.email_already_exists?
      warning = { message: "Email #{data.email} already exists. Keeping the existing one, ignoring the new one.",
        user_uid: data.uid, name: data.name }
      progress.log_warning(warning)
      data.email = nil
    end
    yield(warning)
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

  def user_already_exists?
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
  def name
    "#{first_name} #{last_name}"
  end

  def uid
    d(:uid)
  end

  def email
    d(:mail)
  end
  def email=(email)
    @data_hash[:mail] = email
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
      profile_field = self.profile_fields.build
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

