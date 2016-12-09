require 'spec_helper'

describe Permalink do
  describe "(uniqueness)" do
    specify "permalinks should have unique paths" do
      Permalink.create! path: "foo"
      Permalink.create! path: "bar"
      expect { Permalink.create!(path: "foo") }.to raise_error
    end

    specify "permalinks should have unique paths also for specific hosts" do
      Permalink.create! path: "foo", host: "example.com"
      Permalink.create! path: "bar", host: "example.com"
      expect { Permalink.create!(path: "foo") }.to raise_error
    end

    specify "same paths for different hosts are ok" do
      Permalink.create! path: "foo", host: "example.com"
      Permalink.create! path: "foo", host: "example.org"
      Permalink.count.should == 2
    end

    specify "a path for a specific host is not ok if there is a global definition" do
      Permalink.create! path: "foo"
      expect { Permalink.create!(path: "foo", host: "example.com") }.to raise_error
    end

    specify "a global path is not ok if there is a host-specific definition" do
      Permalink.create! path: "foo", host: "example.com"
      expect { Permalink.create!(path: "foo") }.to raise_error
    end
  end
end