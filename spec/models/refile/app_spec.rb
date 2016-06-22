require 'spec_helper'

describe Refile::App do
  subject { Refile::App }

  its(:sessions) { should be_true }

end