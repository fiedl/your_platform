class Birthday
  attr_accessor :user
  attr_accessor :date
  attr_accessor :age

  def initialize(args)
    self.user = args[:user]
    self.date = args[:date]
    self.age = args[:age]
  end

  def self.upcoming
    users_ordered_by_upcoming_birthday.collect do |user|
      self.new(user: user, date: user.next_birthday, age: user.next_age)
    end
  end

  private

  def self.users_ordered_by_upcoming_birthday(limit: 3)
    User.find(Graph::User.user_ids_order_by_upcoming_birthday(limit: limit)).select { |u| u.date_of_birth.present? }
  end

end