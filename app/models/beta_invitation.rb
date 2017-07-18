class BetaInvitation < ApplicationRecord
  belongs_to :beta
  belongs_to :inviter, class_name: "User"
  belongs_to :invitee, class_name: "User"

  def invitee_title
    invitee.title
  end
  def invitee_title=(t)
    self.invitee = User.find_by_title(t)
  end

  def send_notification_later
    Notification.create(
      recipient_id: invitee.id,
      reference_id: beta.id,
      reference_type: "Beta",
      reference_url: beta.url,
      author_id: inviter.id,
      message: beta.title,
      text: I18n.t(:foo_has_invited_you_to_the_beta_bar, foo: inviter.title, bar: beta.title)
    )
    Notification.delay.deliver_for_user(invitee)
  end

end
