module DecisionMaking

  # In decision making proceeses, there are several options, i.e. choices.
  #
  # @!attribute title [String]
  # @!attribute description [String]
  #
  class Option < ApplicationRecord
    belongs_to :process
  end
end