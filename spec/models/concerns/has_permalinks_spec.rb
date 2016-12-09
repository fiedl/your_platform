require 'spec_helper'

describe HasPermalinks do
  let(:page) { create :page }

  describe "#permalinks_list=" do
    subject { page.permalinks_list = list_input; page.permalink_paths }

    describe "commaseparated list" do
      let(:list_input) { "foo, bar,baz" }
      it { should == %w{foo bar baz} }
    end

    describe "newline-separated list" do
      let(:list_input) { "foo\nbar\nbaz"}
      it { should == %w{foo bar baz} }
    end

    describe "newline-separated list with whitespaces" do
      let(:list_input) { " foo\nbar \nbaz"}
      it { should == %w{foo bar baz} }
    end

    describe "comma- and newline-separated list" do
      let(:list_input) { "foo\nbar, baz"}
      it { should == %w{foo bar baz} }
    end

    describe "white-space separated" do
      let(:list_input) { "foo bar baz" }
      it { should == %w{foo bar baz} }
    end

    describe "for paths with http://" do
      let(:list_input) { "foo, http://example.com/bar, baz" }
      it { should include "foo", "baz" }
      it { should include "https://example.com/bar" }
      it { should_not include "http://example.com/bar" }
      it "should save the host" do
        subject
        page.permalinks.map(&:host).should == [nil, "example.com", nil]
      end
      it "should save the path separately" do
        subject
        page.permalinks.map(&:path).should == ["foo", "bar", "baz"]
      end
    end

    describe "for paths with https://" do
      let(:list_input) { "foo, https://example.com/bar, baz" }
      it { should include "foo", "baz" }
      it { should include "https://example.com/bar" }
      it { should_not include "http://example.com/bar" }
      it "should save the host" do
        subject
        page.permalinks.map(&:host).should == [nil, "example.com", nil]
      end
      it "should save the path separately" do
        subject
        page.permalinks.map(&:path).should == ["foo", "bar", "baz"]
      end
    end

    describe "for absolute paths" do
      let(:list_input) { "/foo, /bar, baz" }
      it { should == %w{foo bar baz} }
    end

    describe "for nested paths" do
      let(:list_input) { "/foo/bar baz/qux/quux" }
      it { should == %w{foo/bar baz/qux/quux} }
    end

    describe "persistence" do
      let(:list_input) { "foo bar baz"}
      it "should persist the permalinks" do
        subject
        Page.find(page.id).permalink_paths.should == %w{foo bar baz}
      end
    end

    specify "changing the permalinks_list should not destroy permalinks (they are permanent!)" do
      page.permalinks_list = "foo bar"
      page.permalink_paths.should == %w{foo bar}
      page.permalinks_list = "bar baz"
      page.permalink_paths.should == %w{foo bar baz}
    end

  end
end