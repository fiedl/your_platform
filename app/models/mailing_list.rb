# This is a conveniance class to access the properties of "mailing lists".
#
# The persistent data is stored in the `ProfileFields::MailingListEmail`, which
# represents the email address, which is associated with a `Group`,
# and in the `Group` and its memberships.
#
class MailingList < ProfileFields::MailingListEmail
  self.table_name = "profile_fields"

  def email
    self.value
  end

  def name
    group_name
  end

  def group_name
    group.name_with_corporation
  end

  def members_count
    group.memberships.length
  end

  def posts
    if self.email.present?
      Post.where(sent_via: self.email)
    else
      Post.none
    end
  end

  def posts_count
    posts.count
  end

  def sender_policy
    group.sender_policy
  end

  def self.all
    ProfileFields::MailingListEmail.includes(:group, :memberships).order(value: :asc).all.collect { |profile_field| profile_field.becomes(MailingList) }
  end

  def self.sti_name
    "ProfileFields::MailingListEmail"
  end

  def self.create_default_mailing_lists
    Corporation.active.all.each do |corporation|
      if corporation.subdomain.present?
        domain = "#{corporation.subdomain}.#{AppVersion.domain}"
        ["Aktivitas", "Burschen", "Fuxen", "Senior (x)", "Fuxmajor (xx)", "Kneipwart (xxx)", "Chargen", "Hauptkassenwart", "Gäste", "Hausbewohner", "Philisterschaft", "Altherrenschaft"].each do |group_name|
          if group = corporation.sub_group(group_name)
            if group.mailing_lists.none?
              email = "#{default_group_name_to_address_mapping(group_name)}@#{domain}"
              group.mailing_lists.create label: "E-Mail-Verteiler", value: email
            end
          else
            logger.warn("Verbindung #{corporation.name} hat keine Gruppe #{group_name}")
          end
        end
        if corporation.mailing_lists.none?
          email = "aktive-und-philister@#{domain}"
          corporation.mailing_lists.create label: "E-Mail-Verteiler", value: email
        end
      else
        logger.warn "Verbindung #{corporation.name} hat keine Subdomain!"
      end
    end
  end

  def self.default_group_name_to_address_mapping(group_name)
    case group_name
    when "Senior", "Senior (x)"
      "x"
    when "Fuxmajor", "Fuxmaior", "Fuxmajor (xx)", "Fuxmaior (xx)"
      "xx"
    when "Kneipwart", "Kneipwart (xxx)"
      "xxx"
    when "Hauptkassenwart"
      "hkw"
    when "Philisterschaft", "Altherrenschaft"
      "philister"
    else
      group_name.downcase.parameterize
    end
  end

end