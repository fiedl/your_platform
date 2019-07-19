# In order to test the group mailing list system, we can have
# test groups that forward the emails to the sender.
#
# A group flagged `:mail_test_group` and having a mailing list
# `test@example.com` bahaves as follows: If a sender sends
# any email to test@example.com, he is assigned to the group,
# the group mail is processed, i.e. forwarded to the sender,
# and then he is unassigned from the group, again.
#
class IncomingMails::TestMail < IncomingMail

  def process(options = {})
    if sender_user && recipient_group && recipient_group.has_flag?(:mail_test_group)
      recipient_group.child_users << sender_user unless recipient_group.child_users.include? sender_user
      recipient_group.update mailing_list_sender_filter: :open
      recipient_group.delete_cache
      result = IncomingMails::GroupMailingListMail.process self.id
      recipient_group.child_users.destroy(sender_user)
      return result
    else
      return []
    end
  end

end