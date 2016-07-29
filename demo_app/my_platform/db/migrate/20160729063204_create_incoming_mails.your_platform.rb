# This migration comes from your_platform (originally 20160728215031)
class CreateIncomingMails < ActiveRecord::Migration
  def change
    create_table :incoming_mails do |t|
      t.string :raw_message
      t.string :message_id
      t.string :in_reply_to_message_id
      t.string :from
      t.text :to
      t.text :cc
      t.string :envelope_to
      t.string :subject
      t.text :content, limit: 1073741823
      t.text :text_content, limit: 1073741823

      t.timestamps null: false
    end
  end
end
