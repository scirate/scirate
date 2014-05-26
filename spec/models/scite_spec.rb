# == Schema Information
#
# Table name: scites
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  paper_uid  :text             default(""), not null
#

require 'spec_helper'

describe Scite do
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:paper) }
end
