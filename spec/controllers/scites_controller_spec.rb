require 'spec_helper'

describe ScitesController do

  let(:user)  { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }

  before { sign_in user }

  describe "creating a scite with Ajax" do

    before { request.env['HTTP_REFERER'] = 'scites/new' }

    it "should increment the Scite count" do
      expect do
        xhr :post, :create, paper_id: paper.id
      end.to change(Scite, :count).by(1)
    end

    it "should respond with success" do
      xhr :post, :create, paper_id: paper.id
      response.should be_success
    end
  end

  describe "destroying a relationship with Ajax" do

    before do
      user.scite!(paper)
      request.env['HTTP_REFERER'] = 'scites/new'
    end

    it "should decrement the Scite count" do
      expect do
        xhr :delete, :destroy, paper_id: paper.id
      end.to change(Scite, :count).by(-1)
    end

    it "should respond with success" do
      xhr :delete, :destroy, paper_id: paper.id
      response.should be_success
    end
  end
end
