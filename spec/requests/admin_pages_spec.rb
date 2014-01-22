require 'spec_helper'

describe "Admin tools" do
  describe "Comment moderation" do
    let(:moderator) { FactoryGirl.create(:user, account_status: User::STATUS_MODERATOR) }
    let(:comment) { FactoryGirl.create(:comment) }
    let(:paper) { comment.paper.reload }

    before { sign_in(moderator) }
    before { visit paper_path(comment.paper) }

    it "shows comment moderation actions" do
      page.should have_content('moderator:')
      page.should have_content('edit')
      page.should have_content('delete')
    end

    it "lets moderators edit comments" do
      xhr :post, edit_comment_path(comment), content: "wubbles"
      response.should be_success
      comment.reload.content.should == "wubbles"
    end

    it "lets moderators delete comments" do
      expect do
        xhr :post, delete_comment_path(comment)
        response.should be_redirect
        flash[:comment][:status].should == 'success'
        paper.reload
      end.to change(paper, :comments_count).by(-1)
    end
  end

  describe "Editing users" do
    let(:moderator) { FactoryGirl.create(:user, account_status: User::STATUS_MODERATOR) }
    let(:admin) { FactoryGirl.create(:user, account_status: User::STATUS_ADMIN) }
    let(:comment) { FactoryGirl.create(:comment) }
    let(:user) { comment.user }

    it "doesn't let moderators edit users" do
      sign_in moderator

      xhr :post, admin_update_user_path(user)
      response.should be_redirect

      visit admin_edit_user_path(user)
      current_path.should == root_path
    end

    it "lets an admin update a user" do
      sign_in admin
      visit admin_edit_user_path(user)
      page.should have_content("admin: editing #{user.username}")

      new_username = "bobbles"
      new_name = "Mr. Bobbles"
      new_email = "bobbles@example.com"
      new_status = User::STATUS_SPAM

      fill_in "Username", with: new_username
      fill_in "Name", with: new_name
      fill_in "Email", with: new_email
      select new_status, from: "Account Status"
      click_button "Save changes"

      user.reload
      user.username.should == new_username
      user.fullname.should == new_name
      user.email.should == new_email
      user.account_status.should == new_status

      # Ensure marking as spam hides comments
      user.comments.where(hidden: true).count.should == 1
    end
  end
end
