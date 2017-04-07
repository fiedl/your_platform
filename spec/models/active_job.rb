require 'spec_helper'

class FailingJob < ApplicationJob
  def perform
    $failing_job_count = ($failing_job_count || 0) + 1
    raise "This job is failing!"
  end
end

describe ActiveJob do
  describe "Patches for ActiveJob::Base" do
    subject { FailingJob.perform_later }

    it "should raise an error finally" do
      expect { subject }.to raise_error
    end

    it "should run 2 times" do
      $failing_job_count = 0
      expect { subject }.to raise_error
      $failing_job_count.should == 2
    end

  end
end