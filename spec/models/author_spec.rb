# == Schema Information
#
# Table name: authors
#
#  id         :integer          not null, primary key
#  position   :integer          not null
#  fullname   :text             not null
#  searchterm :text             not null
#  paper_uid  :text
#

require 'spec_helper'

describe Author do
  before do
    @author = FactoryGirl.create(:author)
  end

  subject { @author }

  it { should respond_to(:fullname) }
  it { should respond_to(:searchterm) }

  it { should be_valid }
end
