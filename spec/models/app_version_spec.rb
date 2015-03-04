require 'spec_helper'

describe AppVersion do
  if ENV['CI'] != 'travis' # because the git commands do not work there.
  
    subject { AppVersion }
    it { should respond_to :last_tag }
    it { should respond_to :version }
    it { should respond_to :commit_id }
    it { should respond_to :short_commit_id }
    it { should respond_to :github_commit_url }
    
    describe ".last_tag" do
      subject { AppVersion.last_tag }
      it { should be_present }
      it { should_not include "\n" }
      it { should start_with "v" }
    end
    describe ".version" do
      subject { AppVersion.version }
      it { should be_present }
      it { should_not include "\n" }
      it { should_not start_with "v" }
    end
    describe ".github_commit_url" do
      subject { AppVersion.github_commit_url }
      it { should == "https://github.com/fiedl/your_platform/commit/#{AppVersion.commit_id}" }
    end
    describe ".changelog_url" do
      subject { AppVersion.changelog_url }
      it { should = "https://github.com/fiedl/your_platform/commits/#{AppVersion.branch}" }
    end
    describe ".app_name" do
      subject { AppVersion.app_name }
      it { should == "MyPlatform" }
    end
  end
end