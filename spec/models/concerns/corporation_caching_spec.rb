require 'spec_helper'

describe CorporationCaching do

  unless ENV['NO_CACHING']

    describe ".cached_methods" do
      subject { Corporation.cached_methods }

      # it "should include methods that are Corporation-specific" do
      #   # We have removed caching status group ids.
      #   # subject.should include :status_group_ids
      # end

      it "should inherit methods from Group" do
        subject.should include :member_table_rows
      end
    end

  end

end