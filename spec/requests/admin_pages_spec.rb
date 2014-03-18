require 'spec_helper'

describe "Admin tools" do
  describe "Comment moderation" do
    before do
      @moderator = FactoryGirl.create(:user, account_status: User::STATUS_MODERATOR) 
      @paper = FactoryGirl.create(:paper_with_comments) 
      @comment = @paper.comments.where(deleted: false).first 
      @deleted_comment = @paper.comments.where(deleted: true).first 
      sign_in(@moderator)
    end

    it "shows moderation actions and deleted comments" do
      visit paper_path(@paper)

      page.should have_content('moderator:')
      page.should have_content('edit')
      page.should have_content('delete')

      page.should have_content("this is a deleted comment")
    end

    it "lets moderators edit comments" do
      xhr :post, edit_comment_path(@comment), content: "wubbles"
      response.should be_success
      @comment.reload.content.should == "wubbles"
    end

    it "lets moderators delete comments" do
      expect do
        xhr :post, delete_comment_path(@comment)
        response.should be_redirect
        flash[:comment][:status].should == 'success'
        @paper.reload
      end.to change(@paper, :comments_count).by(-1)
    end

    it "lets moderators restore comments" do
      expect do
        xhr :post, restore_comment_path(@deleted_comment)
        response.should be_redirect
        flash[:comment][:status].should == 'success'
        @paper.reload
      end.to change(@paper, :comments_count).by(1)
    end
  end

  describe "Editing users" do
    before do
      @moderator = FactoryGirl.create(:user, account_status: User::STATUS_MODERATOR) 
      @admin = FactoryGirl.create(:user, account_status: User::STATUS_ADMIN) 
      @comment = FactoryGirl.create(:comment) 
      @user = @comment.user
    end

    it "doesn't let moderators edit users" do
      sign_in @moderator

      xhr :post, admin_update_user_path(@user)
      response.should be_redirect

      visit admin_edit_user_path(@user)
      current_path.should == root_path
    end

    it "lets an admin update a user" do
      sign_in @admin
      visit admin_edit_user_path(@user)
      page.should have_content("admin: editing #{@user.username}")

      new_username = "bobbles"
      new_name = "Mr. Bobbles"
      new_email = "bobbles@example.com"
      new_status = User::STATUS_SPAM

      fill_in "Username", with: new_username
      fill_in "Name", with: new_name
      fill_in "Email", with: new_email
      select new_status, from: "Account Status"
      click_button "Save changes"

      @user.reload
      @user.username.should == new_username
      @user.fullname.should == new_name
      @user.email.should == new_email
      @user.account_status.should == new_status

      # Ensure marking as spam hides comments
      @user.comments.where(hidden: true).count.should == 1
    end
  end
end
