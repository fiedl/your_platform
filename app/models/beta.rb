class Beta < ApplicationRecord
  has_many :invitations, class_name: "BetaInvitation"
  has_many :invitees, through: :invitations


end
