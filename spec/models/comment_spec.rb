require 'spec_helper'

describe Comment do
  before { @comment = create :comment }
    
  describe "#text=" do
    subject { @comment.text = @text; @comment.save }
    
    describe "for utf-8 strings with 4-byte characters" do
      before { @text = "Hab ich eingetragen, danke 😉Von meinem iPhone gesendet" }
      it "should store the string without any error" do
        expect { subject }.not_to raise_error
      end
      it "should save the text persistantly" do
        subject
        @comment.reload.text.should include "😉"
      end
    end
  end
end
