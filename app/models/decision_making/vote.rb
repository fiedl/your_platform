module DecisionMaking

  # In decision making processes, several parties cast their votes.
  # These parties can be people or groups. If the voter is a group,
  # the group may be represented by a person (representative).
  #
  class Vote < ApplicationRecord
    belongs_to :process
    belongs_to :option
    belongs_to :user
    belongs_to :group
  end
end