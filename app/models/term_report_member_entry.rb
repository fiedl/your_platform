class TermReportMemberEntry < ActiveRecord::Base

  belongs_to :term_report
  belongs_to :user

  # term_report.member_entries.create_from_user user, category: "Active Members"
  #
  def self.create_from_user(user, options = {})
    entry = self.new
    entry.user_id = user.id

    entry.category = options[:category] || options[:status]

    entry.last_name = user.last_name
    entry.first_name = user.first_name
    entry.name_affix = user.name_affix

    entry.date_of_birth = user.date_of_birth

    entry.primary_address = user.study_address
    entry.secondary_address = user.home_address
    entry.phone = user.phone
    entry.email = user.email

    entry.profession = user.primary_study_field.try(:subject)

    entry.save
    return entry
  end

end
