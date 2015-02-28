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
      # TODO: Chancge this when extracting your_platform.
      # Then, we'll need another test, since we don't know the main_app repo then.
      subject { AppVersion.github_commit_url }
      it { should == "https://github.com/fiedl/wingolfsplattform/commit/#{AppVersion.commit_id}" }
    end
    describe ".changelog_url" do
      # TODO: Chancge this when extracting your_platform.
      # Then, we'll need another test, since we don't know the main_app repo then.
      subject { AppVersion.changelog_url }
      it { should = "https://github.com/fiedl/wingolfsplattform/commits/#{AppVersion.branch}" }
    end
    describe ".app_name" do
      # TODO: Chancge this when extracting your_platform.
      # Then, we'll need another test, since we don't know the main_app repo then.
      subject { AppVersion.app_name }
      it { should == "Wingolfsplattform" }
    end
  end
end