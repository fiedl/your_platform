module EmailHelper

  # This helper can be used to scan for emails in the given text
  # and insert spam-protective strings.
  #
  # The original email is reconstructed via javascript in:
  # app/assets/javascripts/your_platform/email_unscrambler.js.coffee
  #
  # For users without javascript, the strings like "without-spam" are
  # readable, i.e. can be removed manually.
  #
  def markup_and_email_scrambler(text)
    markup scramble_emails text
  end

  def scramble_emails(text)
    text.gsub(/[^@\s]+@[^@\s]+/) do |email|
      email.gsub("@", "-without-spam@no-spam-")
    end
  end

end