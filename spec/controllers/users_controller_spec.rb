require 'spec_helper'

describe UsersController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'papers' do
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      user.authorships.create!(paper_uid: paper.uid)
    end

    it "shows authored papers" do
      get :papers, params: { username: user.username}
      expect(assigns(:authored_papers)).to match_array(user.authored_papers)
      expect(response).to render_template("users/profile")
    end
  end

  describe 'scites' do
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      user.scites.create!(paper_uid: paper.uid)
    end

    it "shows scited papers" do
      get :scites, params: { username: user.username }
      expect(assigns(:scited_papers)).to match_array(user.scited_papers)
      expect(response).to render_template("users/profile")
    end
  end

  describe 'comments' do
    let(:paper) { FactoryGirl.create(:paper) }
    let(:comment) { FactoryGirl.create(:comment, paper: paper, user: user) }

    it "shows comments" do
      get :comments, params: { username: user.username }
      expect(assigns(:comments)).to match_array(user.comments)
      expect(response).to render_template("users/profile")
    end
  end
end
