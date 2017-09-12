require 'spec_helper'

describe String do
  describe "#to_datetime" do
    subject { @string.to_datetime }

    describe "for a regular date string in German date format" do
      before { @string = "13.11.2005" }
      its(:year) { should == 2005 }
      its(:month) { should == 11 }
      its(:day) { should == 13 }
    end

    describe "for a regular date string in German date format with illegal spaces" do
      before { @string = "13.11. 2005" }
      its(:year) { should == 2005 }
      its(:month) { should == 11 }
      its(:day) { should == 13 }
    end

    describe "for month and year, e.g. 11/2005" do
      before { @string = "11/2005" }
      its(:year) { should == 2005 }
      its(:month) { should == 11 }
      its(:day) { should == 1 }
    end

    describe "for a year, e.g. 2005" do
      before { @string = "2005" }
      its(:year) { should == 2005 }
      its(:month) { should == 1 }
      its(:day) { should == 1 }
    end

    describe "for something invalid" do
      before { @string = "asd" }
      it "should raise an error" do
        expect { subject }.to raise_error ArgumentError
      end
    end

  end
end