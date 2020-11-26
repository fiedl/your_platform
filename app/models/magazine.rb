class Magazine < ApplicationRecord
  belongs_to :group, optional: true
  belongs_to :editors_group, class_name: "Group", optional: true
  belongs_to :subscribers_group, class_name: "Group", optional: true

  def title
    name
  end

  def avatar
    group.try(:avatar)
  end

  def self.import
    Magazine.where(name: "Wingolfsblätter").first_or_create
    Corporation.all.each do |corporation|
      if magazine_name = corporation.profile_fields.where(label: "Verbindungszeitschrift").first.try(:value)
        Magazine.where(name: magazine_name).first_or_create do |magazine|
          magazine.group = corporation
          magazine.save
        end
      end
    end
  end
end
