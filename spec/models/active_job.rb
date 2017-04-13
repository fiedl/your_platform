require 'spec_helper'

class FailingJob < ApplicationJob
  def perform
    $job_count = ($job_count || 0) + 1
    raise "This job is failing!"
  end
end

class JobPerformingOnRecord < ApplicationJob
  def serialize
    $job_count = ($job_count || 0) + 1
    super
  end

  def perform(record)
    record.touch
  end
end

describe ActiveJob do
  describe "Patches for ActiveJob::Base" do
    describe "for failing jobs" do
      subject { FailingJob.perform_later }

      it "should raise an error finally" do
        expect { subject }.to raise_error
      end

      it "should run 2 times" do
        $job_count = 0
        expect { subject }.to raise_error
        $job_count.should == 2
      end
    end

    describe "for jobs run for deleted records" do
      before { @user = create :user; User.find(@user.id).destroy }
      subject { JobPerformingOnRecord.perform_later(@user) }

      it "should run 2 times, once regularly, once in the retry queue" do
        $job_count = 0
        subject
        $job_count.should == 2
      end

      it "should not raise an error" do
        expect { subject }.not_to raise_error
      end
    end
  end
end