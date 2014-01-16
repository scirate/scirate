# == Schema Information
#
# Table name: authors
#
#  id         :integer          not null, primary key
#  position   :integer          not null
#  fullname   :string(255)      not null
#  searchterm :string(255)      not null
#  paper_uid  :string(255)
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
