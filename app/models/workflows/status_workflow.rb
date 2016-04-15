# A StatusWorkflow moves a user from one group to another.
#
# ## Conversion
#
# To convert other workflows to be a StatusWorkflow, you may use this
# snippet.
#
#     Workflow.pluck(:name).uniq   # => ["Aktivmeldung", "Reception", "Branderung", "Burschung", "Inaktivierung loci",
#                                        "Inaktivierung non loci", "Reaktivierung", "Konkneipierung", "Philistration",
#                                        "Todesfall", "Streichung", "Schlichter Austritt", "Ehrenhafter Austritt",
#                                        "Dimissio i.p.", "Exclusio"]
#
#     Workflow.where(name: ["Reception", "Branderung"]).each do |workflow|
#       workflow.type = "Workflows::StatusWorkflow"
#       workflow.move_from_group_id = workflow.steps.where(brick_name: "RemoveFromGroupBrick")
#         .first.parameters.where(key: 'group_id').first.value
#       workflow.move_to_group_id = workflow.steps.where(brick_name: "AddToGroupBrick")
#         .first.parameters.where(key: 'group_id').first.value
#       workflow.steps.destroy_all
#     end
#
class Workflows::StatusWorkflow < Workflow


  # TODO: Damit das STI funktioniert, muss die Basisklasse `Workflow` sein,
  # nicht `WorkflowKit::Workflow`. Zum Testen: `Workflow.where(name: "Reception", type: nil)`.
  #
  # Außerdem sollten wir die Tabelle von `workflow_kit_workflows` in `workflows` umbenennen.

  belongs_to :move_from_group, class_name: 'Group'
  belongs_to :move_to_group, class_name: 'Group'
  attr_accessor :user

  def execute(params)
    user = User.find params[:user_id] || raise('no :user_id workflow parameter given')

    ActiveRecord::Base.transaction do

      remove_user_from_group
      membership = add_user_to_group
      membership.need_review!
      destroy_user_account_and_end_memberships_if_needed

    end
  end

  private

  # Quit the membership of the user that is passed to this workflow as parameter
  # in the given group.
  #
  def remove_user_from_group
    membership = UserGroupMembership.find_by(user: user, group: move_from_group)
    if membership
      if membership.direct?
        membership.invalidate at: 2.seconds.ago
      else
        membership.direct_memberships.each { |m| m.invalidate at: 2.seconds.ago }
      end
    end
  end

  def add_user_to_group
    UserGroupMembership.create user: user, group: move_to_group
  end

  # If the user is not member of any corporation anymore: Destroy the
  # associated UserAccount. This prevents login but keeps all user data.
  # End all non-corporation memberships.
  #
  def destroy_user_account_and_end_memberships_if_needed
    if user.current_corporations.count == 0
      user.account.try(:destroy)
      user.end_all_non_corporation_memberships
    end
  end

end