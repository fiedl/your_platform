require 'spec_helper'

describe Permalink do
  describe "(uniqueness)" do
    specify "permalinks should have unique paths" do
      Permalink.create! url_path: "foo"
      Permalink.create! url_path: "bar"
      expect { Permalink.create!(url_path: "foo") }.to raise_error
    end

    specify "permalinks should have unique paths also for specific hosts" do
      Permalink.create! url_path: "foo", host: "example.com"
      Permalink.create! url_path: "bar", host: "example.com"
      expect { Permalink.create!(url_path: "foo") }.to raise_error
    end

    specify "same paths for different hosts are ok" do
      Permalink.create! url_path: "foo", host: "example.com"
      Permalink.create! url_path: "foo", host: "example.org"
      Permalink.count.should == 2
    end

    specify "a path for a specific host is not ok if there is a global definition" do
      Permalink.create! url_path: "foo"
      expect { Permalink.create!(url_path: "foo", host: "example.com") }.to raise_error
    end

    specify "a global path is not ok if there is a host-specific definition" do
      Permalink.create! url_path: "foo", host: "example.com"
      expect { Permalink.create!(url_path: "foo") }.to raise_error
    end
  end
end