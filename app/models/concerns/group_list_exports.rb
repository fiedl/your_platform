concern :GroupListExports do

  def export_list(options = {})
    list_export = list_export_by_preset(options[:list_preset] || options[:preset], options)
    case options[:format].to_s
    when 'csv'
      list_export.to_csv
    when 'xls'
      list_export.to_xls
    else
      list_export
    end
  end

  def list_export_by_preset(preset, options = {})
    case preset.to_s
    when 'name_list', '', nil
      self.export_name_list
    when 'address_list'
      self.export_address_list
    when 'member_development'
      self.export_member_development
    when 'join_statistics'
      self.export_join_statistics
    when 'dpag_internetmarken'
      self.export_dpag_internetmarken
    when 'dpag_internetmarken_in_germany'
      self.export_dpag_internetmarken_in_germany
    when 'dpag_internetmarken_not_in_germany'
      self.export_dpag_internetmarken_not_in_germany
    when 'birthday_list'
      self.export_birthday_list(quater: options[:quater])
    when 'email_list'
      self.export_email_list
    when 'special_birthdays'
      self.export_special_birthdays_list(quater: options[:quater])
    when 'deceased_members'
      self.export_deceased_members_list
    when 'former_and_deceased_members'
      self.export_former_and_deceased_members_list
    when 'phone_list'
      self.export_phone_list
    else
      ListExport.new(self.members, preset)
    end
  end

  def export_name_list
    ListExports::NameList.from_group(self)
  end

  def export_address_list
    ListExports::AddressList.from_group(self)
  end

  def export_member_development
    ListExport.new(self, :member_development)
  end

  def export_join_statistics
    ListExport.new(self, :join_statistics)
  end

  def export_dpag_internetmarken
    ListExports::DpagInternetmarken.from_group(self)
  end

  def export_dpag_internetmarken_in_germany
    ListExports::DpagInternetmarkenInGermany.from_group(self)
  end

  def export_dpag_internetmarken_not_in_germany
    ListExports::DpagInternetmarkenNotInGermany.from_group(self)
  end

  def export_birthday_list(options = {})
    ListExports::BirthdayList.from_group(self, quater: options[:quater])
  end

  def export_email_list
    ListExports::EmailList.from_group(self)
  end

  def export_special_birthdays_list(options = {})
    ListExports::SpecialBirthdays.from_group(self, quater: options[:quater])
  end

  def export_deceased_members_list
    ListExports::DeceasedMembers.from_group(self)
  end

  def export_former_and_deceased_members_list
    ListExports::FormerAndDeceasedMembers.from_group(self)
  end

  def export_phone_list
    ListExport.new(self, :phone_list)
  end

  class_methods do
    def export_list_presets
      [
        :name_list,
        :address_list,
        :member_development,
        :join_statistics,
        :dpag_internetmarken,
        :dpag_internetmarken_in_germany,
        :dpag_internetmarken_not_in_germany,
        :birthday_list,
        :email_list,
        :special_birthdays,
        :deceased_members,
        :former_and_deceased_members,
        :phone_list
      ]
    end
  end

end