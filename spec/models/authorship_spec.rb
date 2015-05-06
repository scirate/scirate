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
  it { is_expected.to validate_presence_of(:paper) }
  it { is_expected.to validate_presence_of(:user) }
end
