module DecisionMaking

  class Signature < ApplicationRecord
    belongs_to :user
    belongs_to :signable, polymorphic: true
  end
end