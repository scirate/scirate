# == Schema Information
#
# Table name: authorships
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  paper_uid  :text             not null
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Authorship do
  it { should validate_presence_of(:paper) }
  it { should validate_presence_of(:user) }
end
