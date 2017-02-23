concern :PageCaching do

  # Make sure this concern is included at the bottom of the class.
  # Otherwise the methods to cache are not defined, yet.
  #
  included do
    cache :group_id
  end

  include StructureableRoleCaching
end