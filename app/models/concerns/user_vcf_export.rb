concern :UserVcfExport do

  def to_vcf
    vcard.name "#{last_name} #{name_affix}", first_name
    vcard.fullname title
    vcard.org corporation.name
    #vcard.photo avatar_base64, encoding: 'b', type: 'PNG'
    vcard.photo avatar_url, type: 'url'
    vcard.bday date_of_birth.to_s

    profile_fields.each do |profile_field|
      key = "item#{profile_field.id}"
      if profile_field.vcard_property_type
        vcard[key].add 'label', profile_field.label
        vcard[key].add 'X-ABLabel', profile_field.label
        vcard[key].add profile_field.vcard_property_type, profile_field.value.try(:gsub, "\n", ";")
      end
    end

    vcard.to_s
  end

  def vcard_path
    Rails.application.routes.url_helpers.user_path(self, format: 'vcf')
  end

  private

  def vcard
    @vcard ||= VCardigan.create version: 3.0
  end

end