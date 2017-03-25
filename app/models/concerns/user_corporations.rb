# This module contains all the Corporation-related methods of a User.
#
# A user can be member of several corporations. Therefore,
# User responds to `User#corporations`.
#
# There is also a usecase, where a User should have a primary corporation
# or be just in one Corporation at all. For those usecases, we provide
# the `User#corporation` method---and the `User#corporation_name` method,
# which is more convenient for the view layer.
#
concern :UserCorporations do

  def corporation_id
    (Corporation.pluck(:id) & self.ancestor_group_ids).first
  end

  # Returns the (single) Corporation the user is associated with.
  # If in your domain, a User is member of several corporations,
  # use the `corporations` method instead.
  #
  def corporation
    Corporation.find corporation_id if corporation_id
  end

  # Returns the name of the Corporation the user is associated with.
  #
  def corporation_name
    corporation.try(:name)
  end

  # Sets the name of the Corporation the user is associated with.
  # If no matching corporation exists, the corporation is created.
  # The user is added as member to this corporation.
  #
  def corporation_name=(new_corporation_name)
    Corporation.find_or_create_by(name: new_corporation_name).assign_user self
  end

end