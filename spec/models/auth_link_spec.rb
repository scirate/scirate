# == Schema Information
#
# Table name: auth_links
#
#  id               :integer          not null, primary key
#  provider         :string(255)      not null
#  uid              :string(255)      not null
#  oauth_token      :string(255)      not null
#  oauth_expires_at :datetime         not null
#  user_id          :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe AuthLink do
  pending "add some examples to (or delete) #{__FILE__}"
end
