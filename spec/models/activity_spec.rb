require 'spec_helper'

describe Activity do
  it { should validate_presence_of(:user) }
end
