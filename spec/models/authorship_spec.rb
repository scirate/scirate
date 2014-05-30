require 'spec_helper'

describe Authorship do
  it { should validate_presence_of(:paper) }
  it { should validate_presence_of(:user) }
end
