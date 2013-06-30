require 'spec_helper'

describe Authorship do
  let(:author) { FactoryGirl.create(:author) }
  let(:paper) { FactoryGirl.create(:paper) }

  before do
    @authorship = author.authorships.create(paper_id: paper.id)
  end

  subject { @authorship }

  it { should respond_to(:author_id) }
  it { should respond_to(:paper_id) }
  
  it { should be_valid }
end
