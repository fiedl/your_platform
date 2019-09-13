concern :GroupDummyUsers do
  
  def generate_dummy_users(number_of_users = 10)
    number_of_users.times { generate_dummy_user }
  end
  
  def generate_dummy_user
    Faker::Config.locale = Setting.preferred_locale || 'de'
    
    user = User.new
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
    user.email = Faker::Internet.email
    user.date_of_birth = Faker::Date.between(from: 30.years.ago, to: 18.years.ago)
    user.save
    
    user.profile_fields.create(label: :personal_title, type: "ProfileFields::General")
    user.profile_fields.create(label: :academic_degree, type: "ProfileFields::AcademicDegree")
    
    user.profile_fields.create label: :home_address, 
      value: "#{Faker::Address.street_address}\n#{Faker::Address.zip} #{Faker::Address.city}\n#{Faker::Address.country}",
      type: "ProfileFields::Address"
    user.profile_fields.create label: :study_address,
      value: "#{Faker::Address.street_address}\n#{Faker::Address.zip} #{Faker::Address.city}\n#{Faker::Address.country}",
      type: "ProfileFields::Address"
    user.profile_fields.create label: :phone, 
      value: Faker::PhoneNumber.phone_number,
      type: "ProfileFields::Phone"
    user.profile_fields.create label: :mobile, 
      value: Faker::PhoneNumber.cell_phone,
      type: "ProfileFields::Phone"
    user.profile_fields.create label: :fax,
      value: Faker::PhoneNumber.phone_number,
      type: "ProfileFields::Phone"
    user.profile_fields.create label: :homepage,
      value: "https://#{Faker::Internet.domain_name}",
      type: "ProfileFields::Homepage"

    self.assign_user user, at: Faker::Date.between(from: 6.years.ago, to: 10.days.ago)
    return user
  end
  
end