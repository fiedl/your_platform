require 'spec_helper'

describe GraphDatabase::Base do

  describe "when no interface is configured" do
    before { Rails.configuration.x.neo4j_rest_url = nil }

    describe "creating a group" do
      subject { create :group }
      it "should not raise an error" do
        expect { subject }.not_to raise_error
      end
      it "should create the group" do
        g = subject
        g.should be_kind_of Group
        g.id.should be_present
      end
    end
  end

end