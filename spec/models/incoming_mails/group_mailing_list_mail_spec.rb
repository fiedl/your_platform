require 'spec_helper'

describe IncomingMails::GroupMailingListMail do
  describe "#process" do
    subject { IncomingMails::GroupMailingListMail.from_message(example_raw_message).process }

    let(:example_raw_message) { %{
      From: john@example.com
      To: all-developers@example.com
      Subject: Great news for all developers!
      Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

      Free drinks this evening!
    }.gsub("  ", "") }

    let(:developers_group) {
      group = create :group, name: "Developers"
      group.mailing_lists.create label: "Mailing list", value: "all-developers@example.com"
      group
    }
    let(:john_doe) {
      create :user_with_account, email: 'john@example.com', locale: 'en'
    }

    before do
      ActionMailer::Base.deliveries = []
      @group = developers_group
      @user = john_doe
      @member = create :user_with_account, locale: 'en'
      @group << @member
    end

    shared_examples_for "nothing to do" do
      it 'does not send any email' do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end
      it 'does not create any post' do
        expect { subject }.not_to change { Post.count }
      end
      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end
      it { should == [] }
    end

    shared_examples_for "forwarding the message" do
      it 'forwards the email to the members with account' do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by 1
        last_email.smtp_envelope_to.should == [@member.email]
        last_email.to.should == ['all-developers@example.com']
        last_email.from.should == ['john@example.com']
        last_email.subject.should include 'Great news for all developers!'
        last_email.body.should include 'Free drinks this evening!'
      end
      it 'does create a post' do
        expect { subject }.to change { Post.count }.by 1
      end
      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end
    end

    describe "when the sender is unknown" do
      before { @user.destroy }
      it_behaves_like 'nothing to do'

      describe "when the mailing list is open" do
        before { @group.update! mailing_list_sender_filter: :open }
        it_behaves_like 'forwarding the message'
      end
    end
    describe "when the recipient is unknwon" do
      before { @group.destroy }
      it_behaves_like 'nothing to do'
    end
    describe "when sender and recipient group exist" do
      describe "when the sender is unauthorized" do
        it_behaves_like "nothing to do"
      end
      describe "when the sender is authorized" do
        before do
          @group.update! mailing_list_sender_filter: :open
        end
        it_behaves_like 'forwarding the message'
        describe "when the group has no members" do
          before { @member.destroy }
          it 'does not send any email' do
            expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
          end
          it 'does create a post' do
            expect { subject }.to change { Post.count }.by 1
          end
          it 'does not raise an error' do
            expect { subject }.not_to raise_error
          end
        end

        it "creates a post" do
          subject
          post = @group.posts.last
          post.author.should == @user
          post.title.should == "Great news for all developers!"
          post.message_id.should == "579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com"
          post.text.should include "Free drinks this evening!"
          post.sent_via.should == "all-developers@example.com"
        end
      end
    end

    describe "when, by forwarding rules, the email has several X-Original-To headers" do
      let(:example_raw_message) { %{
        From: john@example.com
        To: all-developers@example.com
        Subject: Great news for all developers!
        X-Original-To: all-developers-relay@example.com
        X-Original-To: all-developers@example.com
        Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

        Free drinks this evening!
      }.gsub("  ", "") }
      before do
        @group.update! mailing_list_sender_filter: :open
      end
      it_behaves_like 'forwarding the message'
    end

    describe "when the body contains a utf-8-🍕" do
      let(:example_raw_message) { %{
        From: john@example.com
        To: all-developers@example.com
        Subject: Great news for all developers!
        Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

        Free drinks and 🍕 this evening!
      }.gsub("  ", "") }
      before do
        @group.update! mailing_list_sender_filter: :open
        @member = create :user_with_account, locale: 'en'
        @group << @member
      end
      it 'forwards the mail with 🍕' do
        subject
        last_email.body_in_utf8.should include '🍕'
      end
      it 'creates a post with 🍕' do
        subject
        post = @group.posts.last
        post.text.should include "🍕"
      end
    end

    describe "when the body contains the {{greeting}} placeholder" do
      let(:example_raw_message) { %{
        From: john@example.com
        To: all-developers@example.com
        Subject: Great news for all developers!
        Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

        {{greeting}}!

        I have great news for you!
      }.gsub("  ", "") }
      before do
        @group.update! mailing_list_sender_filter: :open
      end
      it "replaces the {{greeting}} placeholder with the personal greeting for the recipient" do
        subject
        last_email.body.should include "Dear #{@member.name}!"
      end

      describe "when the group has several members" do
        before do
          @james = create :user_with_account, first_name: "James", last_name: "Bond", locale: 'en'; @group << @james
          @alec = create :user_with_account, first_name: "Alec", last_name: "Trevelyan", locale: 'en'; @group << @alec
        end
        it "replaces the {{greeting}} placeholder with the personal greeting for the recipient" do
          subject
          ActionMailer::Base.deliveries[-1].to_s.should include "Dear Alec Trevelyan"
          ActionMailer::Base.deliveries[-2].to_s.should include "Dear James Bond"
        end
      end

      describe "when the message contains an attachment" do
        let(:example_raw_message) {
          message = Mail::Message.new %{
            From: john@example.com
            To: all-developers@example.com
            Subject: Great news for all developers!
            Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

            {{greeting}}!

            I have great news for you!
          }.gsub("  ", "")
          message.add_file File.expand_path(File.join(__FILE__, '../../../support/uploads/pdf-upload.pdf'))
          message
        }
        it "replaces the {{greeting}} placeholder with the personal greeting for the recipient" do
          subject
          last_email.to_s.should include "Dear #{@member.name}!"
          last_email.to_s.should_not include "{{greeting}}"
        end

        describe "when the message has a text and an html part" do
          before do
            example_raw_message.text_part = "{{greeting}}! I have great news for you!"
            example_raw_message.html_part = "<i>{{greeting}}!</i> I have <b>great news</b> for you!"
          end
          it "replaces the {{greeting}} placeholder with the personal greeting for the recipient" do
            subject
            last_email.to_s.should include "Dear #{@member.name}!"
            last_email.to_s.should_not include "{{greeting}}"
          end
        end

        it "creates a post with attachment" do
          subject
          attachment = @group.posts.last.attachments.first
          attachment.filename.should == "pdf-upload.pdf"
          attachment.content_type.should == "application/pdf"
        end
      end

      describe "when the message has a text and an html part and an attachment" do
        let(:example_raw_message) { %{
          From: john@example.com
          Content-Type: multipart/alternative;
          	boundary="Apple-Mail=_E2146AB0-89EF-44D4-8F48-45D19A8B9191"
          Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
          Subject: Test 2
          X-Universally-Unique-Identifier: AC83BF47-7EED-4608-AEE5-0058D91C783C
          To: all-developers@example.com

          --Apple-Mail=_E2146AB0-89EF-44D4-8F48-45D19A8B9191
          Content-Transfer-Encoding: 7bit
          Content-Type: text/plain;
          	charset=us-ascii

          {{greeting}}!

          Test!


          --Apple-Mail=_E2146AB0-89EF-44D4-8F48-45D19A8B9191
          Content-Type: multipart/related;
          	type="text/html";
          	boundary="Apple-Mail=_4CEDCFA4-0D1F-4DF7-AB0E-CA1177641839"


          --Apple-Mail=_4CEDCFA4-0D1F-4DF7-AB0E-CA1177641839
          Content-Transfer-Encoding: 7bit
          Content-Type: text/html;
          	charset=us-ascii

          <html><head><meta http-equiv="Content-Type" content="text/html; charset=us-ascii"></head><body style="word-wrap: break-word; -webkit-nbsp-mode: space; line-break: after-white-space;" class="">{{greeting}}!<div class=""><br class=""></div><div class="">Test!</div><div class=""><br class=""></div><div class=""><img apple-inline="yes" id="9FF2F7C6-6539-4B16-8302-5A5DE93D1A96" width="194" height="166" src="cid:16F88EC1-6EFB-4AA1-9095-90D64F5B82D7@Speedport_W_724V_01011603_06_003" class=""></div></body></html>
          --Apple-Mail=_4CEDCFA4-0D1F-4DF7-AB0E-CA1177641839
          Content-Transfer-Encoding: base64
          Content-Disposition: inline;
          	filename=image-upload.png
          Content-Type: image/png;
          	x-unix-mode=0644;
          	name="image-upload.png"
          Content-Id: <16F88EC1-6EFB-4AA1-9095-90D64F5B82D7@Speedport_W_724V_01011603_06_003>

          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
          vel6lXrH9Np4BM+aF8XL5S3jHeTd5H0cZjwsaJh42OJh+4ZdHfZOf7h+oL5Yv1R/v/4N/Y8GfIMw
          gxyDFQZ1BvcNSUN7w/GG0ww3GZ427BquO9x3uHB46fCDw38zwo3sjeKNZhptM7pk1GNsYhxhLDde
          Z3zKuMuEZxJokm2yyuS4Sacp19TfVGq6yvSE6TO+Hj+In8tfy2/md5sZmUWaKc22mrWY9ZrbmCeZ
          LzDfb37fgmnhZZFpscqiyaLb0tRyrOUsyxrL36zUrbysJFZrrM5avbO2sU6xXmRdZ91ho28TZVNs
          U2Nzz5ZtG2Cbb1tle92Obudll2O30e6KPW7vbi+xr7S/7IA7eDhIHTY6tI6gjfAeIRtRNeKWI8sx
          yLHIscbx4UjeyJiRC0bWjXwxynJU2qgVo86O+uLk7pTrtN3prrOO8xjnBc4Nzq9c7F2ELpUu113Z
          ruGuc13rXV+6ObiJ3Ta53Xbnuo91X+Te5P7Zw9ND4bHPo9PT0jPdc4PnLS9drzivJV7nvGnewd5z
          vY96f/Dx8Cn0Oejzp6+jb47vbt+O0TajxaO3j37sZ+4n8Nvq1+bP90/33+LfFmAWIAioCngUaBEo
          CtwR+DTILig7aE/Qi2CnYEXw4eB3IT4hs0MaQ4nQiNDS0JYwnbCksPVhD8LNw7PCa8K7I9wjZkY0
          RtIioyNXRN6KMo4SRlVHdY/xHDN7THM0Kzohen30oxj7GEVMw1h87JixK8feG2c1TjauLhZio2JX
          xt6Ps4nLj/tlPH183PjK8U/ineNnxZ9N4CZMSdid8DYxOHFZ4t0k2yRlUlOyZvLE5OrkdymhKeUp
          bRNGTZg94WKqYao0tT6NkZactiOt55uwb1Z/0z7RfWLJxJuTbCZNn3R+suHk3MnHpmhOEUw5lE5L
          T0nfnf5JECuoEvRkRGVsyOgWhgjXCJ+LAkWrRJ1iP3G5+GmmX2Z5ZkeWX9bKrE5JgKRC0iUNka6X
          vsyOzN6c/S4nNmdnTl9uSu7+PLW89LwjMh1Zjqx5qsnU6VNb5Q7yEnlbvk/+6vxuRbRiRwFWMKmg
          vlAXHZ4vKW2V3ykfFvkXVRa9n5Y87dB07emy6Zdm2M9YPONpcXjxjzPJmcKZTbPMZs2f9XB20Oyt
          c7A5GXOa5lrMXTi3fV7EvF3zmfNz5v+6wGlB+YI336Z827DQeOG8hY+/i/iupoRToii5tch30ebv
          ye+l37csdl28bvGXUlHphTKnsoqyT0uESy784PzD2h/6lmYubVnmsWzTcvpy2fKbKwJW7CrXLi8u
          f7xy7MraVfxVpaverJ6y+nyFW8XmNcw1yjVta2PW1q+zXLd83af1kvU3KoMr928w2rB4w7uNoo1X
          NwVu2rfZeHPZ5o9bpFtub43YWltlXVWxjb6taNuT7cnbz/7o9WP1DsMdZTs+75TtbNsVv6u52rO6
          erfR7mU1eI2ypnPPxD1X9oburd/nuG/rft7+sgNwQHng2U/pP908GH2w6ZDXoX0/W/284TD3cGkt
          VjujtrtOUtdWn1rfemTMkaYG34bDv4z8ZedRs6OVx/SOLTvOPL7weN+J4hM9jfLGrpNZJx83TWm6
          e2rCqevN45tbTkefPncm/Myps0FnT5zzO3f0vM/5Ixe8LtRd9LhYe8n90uFf3X893OLRUnvZ83L9
          Fe8rDa2jW49fDbh68lrotTPXo65fvDHuRuvNpJu3b0281XZbdLvjTu6dl78V/dZ7d9492r3S+1r3
          Kx4YPaj6j91/9rd5tB17GPrw0qOER3cfCx8//73g90/tC5+wn1Q8NX1a3eHScbQzvPPKs2+etT+X
          P+/tKvlD+48NL2xf/Pxn4J+Xuid0t79UvOx7teS1weudb9zeNPXE9Tx4m/e2913pe4P3uz54fTj7
          MeXj095pnxif1n62+9zwJfrLvb68vj65QCFQnQUI1OOZmQCvdgKwU9HZ4QoAk9P/zaXywPq/ExHG
          BhpF/w33f5dRBnSGgJ2BAEnzAGIaATahZoUwC92p43diIOCurkMNMdRVkOnqogIYS4GOJu/7+l4b
          AzAaAD4r+vp6N/b1fd6Ozup3ABrz+7/1KG/qG3ILOvMD/GqxiLr9z/Vf1yhpoZGSUmEAAAAJcEhZ
          cwAAFiUAABYlAUlSJPAAAAGdaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHht
          bG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA1LjQuMCI+CiAgIDxyZGY6
          UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5z
          IyI+CiAgICAgIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5z
          OmV4aWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPGV4aWY6UGl4
          ZWxYRGltZW5zaW9uPjM4ODwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBp
          eGVsWURpbWVuc2lvbj4zMzI8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNj
          cmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KCDt8lwAAMQRJREFUeAHtnWmTHdd5
          33vvu987+wy2AUBslGhwk0hTCilRjORSHJeTvIirUimn7Co5rtifIJ8kL+PkRSpJ2a5yYiuJTUqU
          uICEBRIgQWIHBhjMvty993Py9AxnMDOYGdzb07dvd8+/xRLu7dvnOc/5ndP/OfsR/+Nf/ljABQIg
          cGgIHC0c+zenXzHv/zUX1VglWoqVN3AGBECg1wRU7hY0l3Pe64i6tQ8x6pYYngeBZBMQBVv2mlyI
          3bsfO4eSnc/wHgRiT4B5NrOWBTF2jkKMYpclcAgEekqAMdu1qiJqRj2lDOMgAALPIOA3zxi3q894
          rB8/o2bUD+qIEwT6REASMwP6qOtYghi7dz92DvUpjxAtCBwKAnktd7R41HW9GKYWYhTDTIFLINAr
          AllFmSgM2BCjXgGGXRAAgc4IqII0WtCZxzp7PNKnUDOKFDciA4H+ElC4k5MMFrsJjz4ViFF/ywZi
          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
          whYIgEBgAhCjwOgQEARAIEwCEKMwacIWCIBAYAIQo8DoEBAEQCBMAhCjMGnCFgiAQGACEKPA6BAQ
          BEAgTAIQozBpwhYIgEBgAhCjwOgQEARAIEwCEKMwacIWCIBAYAIQo8DoEBAEQCBMAhCjMGnCFgiA
          QGACEKPA6BAQBEAgTAIQozBpwhYIgEBgAhCjwOgQEARAIEwCEKMwacIWCIBAYAIQo8DoEBAEQCBM
          AhCjMGnCFgiAQGACEKPA6BAQBEAgTAIQozBpwhYIgEBgAhCjwOgQEARAIEwCEKMwacIWCIBAYAIQ
          o8DoEBAEQCBMAhCjMGnCFgiAQGACEKPA6BAQBEAgTAIQozBpwhYIgEBgAhCjwOgQEARAIEwCEKMw
          acIWCIBAYAIQo8DoEBAEQCBMAhCjMGnCFgiAQGACEKPA6BAQBEAgTAIQozBpwhYIgEBgAhCjwOgQ
          EARAIEwCEKMwacIWCIBAYAIQo8DoEBAEQCBMAhCjMGnCFgiAQGACEKPA6BAQBEAgTAIQozBpwhYI
          gEBgAhCjwOgQEARAIEwCEKMwacIWCIBAYAIQo8DoEBAEQCBMAhCjMGnCFgiAQGACEKPA6BAQBEAg
          TAIQozBpwhYIgEBgAhCjwOgQEARAIEwCEKMwacIWCIBAYAIQo8DoEBAEQCBMAhCjMGnCFgiAQGAC
          EKPA6BAQBEAgTAIQozBpwhYIgEBgAhCjwOgQEARAIEwCEKMwacIWCIBAYAIQo8DoEBAEQCBMAhCj
          MGnCFgiAQGACEKPA6BAQBEAgTAIQozBpwhYIgEBgAhCjwOgQEARAIEwCEKMwacIWCIBAYAIQo8Do
          EBAEQCBMAhCjMGnCFgiAQGACEKPA6BAQBEAgTAIQozBpwhYIgEBgAhCjwOgQEARAIEwCEKMwacIW
          CIBAYAIQo8DoEBAEQCBMAhCjMGnCFgiAQGACEKPA6BAQBEAgTAIQozBpwhYIgEBgAhCjwOgQEARA
          IEwCEKMwacIWCIBAYAIQo8DoEBAEQCBMAhCjMGnCFgiAQGACEKPA6BAQBEAgTAIQozBpwhYIgEBg
          AhCjwOgQEARAIEwCEKMwacIWCIBAYAIQo8DoEBAEQCBMAhCjMGnCFgiAQGACEKPA6BAQBEAgTAIQ
          ozBpwhYIgEBgAhCjwOgQEARAIEwCEKMwacIWCIBAYAIQo8DoEBAEQCBMAhCjMGnCFgiAQGACEKPA
          6BAQBEAgTAIQozBpwhYIgEBgAhCjwOgQEARAIEwCEKMwacIWCIBAYAIQo8DoEBAEQCBMAhCjMGnC
          FgiAQGACEKPA6BAQBEAgTAIQozBpwhYIgEBgAhCjwOgQEARAIEwCEKMwacIWCIBAYAL/H7Jb82jl
          OwfXAAAAAElFTkSuQmCC
          --Apple-Mail=_4CEDCFA4-0D1F-4DF7-AB0E-CA1177641839--

          --Apple-Mail=_E2146AB0-89EF-44D4-8F48-45D19A8B9191--
        }.gsub("  ", "") }
        before do
          @group.update! mailing_list_sender_filter: :open
        end
        it "replaces the {{greeting}} placeholder with the personal greeting for the recipient" do
          subject
          last_email.to_s.should include "Dear #{@member.name}!"
          last_email.to_s.should_not include "{{greeting}}"
        end
      end
    end

    describe "when the recipient group has a name" do
      before do
        @group.name = "All Developers"
        @group.mailing_list_sender_filter = :open
        @group.save
      end
      describe "when the group is the sole 'To' recipient" do
        it "injects the recipient-group name into the To field" do
          subject
          last_email["To"].to_s.should include "All Developers"
        end
      end
      describe "when the 'To' recipient has already a formatted name" do
        let(:example_raw_message) { %{
          From: john@example.com
          To: Developers <all-developers@example.com>
          Subject: Great news for all developers!
          X-Original-To: all-developers@example.com
          Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

          Free drinks this evening!
        }.gsub("  ", "") }
        it "rewrites the field" do
          subject
          last_email["To"].to_s.should include "All Developers"
        end
      end
      describe "when the 'To' recipient has already a formatted name with a comma" do
        let(:example_raw_message) { %{
          From: john@example.com
          To: "Developers, All" <all-developers@example.com>
          Subject: Great news for all developers!
          X-Original-To: all-developers@example.com
          Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

          Free drinks this evening!
        }.gsub("  ", "") }
        it "rewrites the field" do
          subject
          last_email["To"].to_s.should include "All Developers"
          last_email["To"].to_s.should_not include "Developers, All"
        end
      end
      describe "when the group is one of two 'To' recipients" do
        let(:example_raw_message) { %{
          From: john@example.com
          To: all-developers@example.com, foo@example.com
          Subject: Great news for all developers!
          X-Original-To: all-developers@example.com
          Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

          Free drinks this evening!
        }.gsub("  ", "") }
        it "injects the recipient-group name into the To field" do
          subject
          last_email["To"].to_s.should include "All Developers"
          last_email["To"].to_s.should include "all-developers@example.com"
          last_email["To"].to_s.should include "foo@example.com"
        end
      end
      describe "when the group is one of two 'CC' recipients" do
        let(:example_raw_message) { %{
          From: john@example.com
          To: foo@example.com
          CC: bar@example.com, "Developers" <all-developers@example.com>
          Subject: Great news for all developers!
          X-Original-To: all-developers@example.com
          Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

          Free drinks this evening!
        }.gsub("  ", "") }
        it "injects the recipient-group name into the CC field" do
          subject
          last_email["CC"].to_s.should include "All Developers"
          last_email["CC"].to_s.should include "all-developers@example.com"
          last_email["CC"].to_s.should include "bar@example.com"
        end
        it "leaves the To field unchanged" do
          subject
          last_email["To"].to_s.should == Mail::Message.new(example_raw_message)["To"].to_s
          last_email["To"].to_s.should_not include "all-developers@example.com"
        end
      end
      describe "when the group is in the BCC field" do
        let(:example_raw_message) { %{
          From: john@example.com
          To: foo@example.com
          CC: "Bar" <bar@example.com>
          Subject: Great news for all developers!
          X-Original-To: all-developers@example.com
          Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

          Free drinks this evening!
        }.gsub("  ", "") }
        it "leaves the To field unchanged" do
          subject
          last_email["To"].to_s.should == Mail::Message.new(example_raw_message)["To"].to_s
          last_email["To"].to_s.should_not include "all-developers@example.com"
        end
        it "leaves the CC field unchanged" do
          subject
          last_email["CC"].to_s.should == Mail::Message.new(example_raw_message)["CC"].to_s
          last_email["CC"].to_s.should_not include "all-developers@example.com"
        end
      end
    end

  end
end

