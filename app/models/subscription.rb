class Subscription < ApplicationRecord

  belongs_to :group

  def price_per_quater
    price_per_quater_and_member * group.members.count
  end

  def paid_until
  end

  def active?
    paid_until && (paid_until >= Time.zone.now)
  end

end
