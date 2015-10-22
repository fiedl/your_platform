require 'spec_helper'

feature "Posts Html Filter" do
  # The filter prevents malicious code from emails from being displayed in posts#index
  # or posts#show.
  #
  # See also: https://trello.com/c/7w1ljO6x/920-posts-nur-spezifische-html-tags-zulassen
  #
  
  include SessionSteps
  
  before do
    @malicious_mail_text = "\n<HTML><BODY><p style='margin-top: 0px;' dir=\"ltr\"></p>\n<p dir=\"ltr\">--<br>\nGesendet von der myMail-App f&#252;r Android</p>\n-------- Forwarded message --------\nVon: Marc Mustermann <<a href=\"mailto:marckrischer@example.com\">marckrischer@example.com</a>>\nCc: \"<a href=\"mailto:<a href=\"mailto:chargen@example.com\">chargen@example.com</a>\"><a href=\"mailto:chargen@example.com\">chargen@example.com</a></a>\" <<a href=\"mailto:<a href=\"mailto:chargen@example.com\">chargen@example.com</a>\"><a href=\"mailto:chargen@example.com\">chargen@example.com</a></a>>\nDatum: Montag, 19 Oktober 2015, 02:05PM +02:00\nBetreff: Antrag fürs Konvent und Dispens<br><br><blockquote style='border-left:1px solid #FC2C38; margin:0px 0px 0px 10px; padding:0px 0px 0px 10px;' cite=\"14452563290000100671\">\n\t\n\n\n\n \n\n\n\n\n\n\n\n\n\n\n\t\n\t\n\n\t\n\t\n\t\n\t\n\t\n\n\t\n\n\t\n\t\n\n\t\n\t\n\t\n\n\t\n\t\n\n\n\n<div class=\"js-helper js-readmsg-msg\">\n\t<style type=\"text/css\"></style>\n \t<div >\n\t\t<base target=\"_self\" href=\"https://e-aj.my.com/\" />\n\t\t\n\t\t\t<div id=\"style_14452563290000100671_BODY\">\n\n\n<div dir='ltr'>Sehr geehrte Chargen,<div><br></div><div>Ich bitte aus dem gleichen Grund wie letzte Woche um Dispens.</div><div><br></div><div>Mit Schwarz-Weiß-Goldenem Gruß<br>Marc Mustermann&nbsp;</div> \t\t \t \t\t </div>\n</div>\n\t\t\t\n\t\t\n\t\t<base target=\"_self\" href=\"https://e-aj.my.com/\" />\n\t</div>\n\n\t\n</div>\n\n\n</blockquote></BODY></HTML>\n"
    @group = create :group
    @user = create :user_with_account; @group << @user
    @author = create :user
    @post = @group.posts.create(subject: "Dispens", text: @malicious_mail_text, group: @group, author: @author, content_type: 'html')
  end
  
  scenario "Looking at the post and making sure the malicious code is not inserted." do
    login @user
    visit post_path(@post)
    
    page.should have_text "Dispens"
    page.should have_text "Mit Schwarz-Weiß-Goldenem Gruß"
    page.should have_text "Marc Mustermann"
    page.should have_no_text "e-aj.my.com"
  end
  
  scenario "Looking at the group posts and making sure the malicious code is not inserted." do
    login @user
    visit group_posts_path(@group)
    
    page.should have_text "Dispens"
    page.should have_text "Mit Schwarz-Weiß-Goldenem Gruß"
    page.should have_text "Marc Mustermann"
    page.should have_no_text "e-aj.my.com"
  end
  
end