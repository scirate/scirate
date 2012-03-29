require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in(user)
      visit user_path(user)
    end

    it { should have_heading user.name }
    it { should have_title user.name }
    it { should have_content "Scites #{user.scites.count}" }
    it { should have_content "Comments #{user.comments.count}" }
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_heading 'Sign up' }
    it { should have_title 'Sign up' }
  end

  describe "signup" do

    before { visit signup_path }

    describe "with invalid information" do
      it "should not create a user" do
        expect { signup }.not_to change(User, :count)
      end
    end

    describe "error messages" do
      before { signup }

      let(:error) { 'errors prohibited this user from being saved' }

      it { should have_title 'Sign up' }
      it { should have_content(error) }
    end

    describe "with valid information" do
      it "should create a user" do
        expect { valid_signup }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { valid_signup(email: 'test-new@example.com') }
        let(:user) { User.find_by_email('test-new@example.com') }

        it { should have_title "" }
        it { should have_success_message 'Welcome to Scirate!' }
        it { should have_success_message user.email }
      end
    end

    describe "account confirmation" do

      describe "new signup is inactive" do
        let(:user) { User.find_by_email('test-new@example.com') }

        before do
          visit signup_path
          valid_signup(email: 'new@example.com', password: 'foobar')

          visit signin_path
          fill_in "Email",    with: 'new@example.com'
          fill_in "Password", with: 'foobar'
          click_button "Sign in"
        end

        it { should have_title "" }
        it { should have_content "Account is inactive!" }
      end

      describe "emails user on signup" do
        before do
          visit signup_path
          valid_signup(email: 'test-new@example.com')
        end

        let(:user) { User.find_by_email('test-new@example.com') }

        it { should have_title "" }
        it { should have_content("Confirmation mail sent to: #{user.email}") }

        it "should send the email" do
          last_email.to.should include(user.email)
        end
      end

      describe "does not email on invalid signup" do
        before do
          visit signup_path
          signup
        end

        it "should not send email" do
          last_email.should be_nil
        end
      end

      describe "activation" do
        let(:user) { FactoryGirl.create(:user,
                                        active: false,
                                        confirmation_token: "i-am-a-token",
                                        confirmation_sent_at: 2.hours.ago) }

        describe "with valid information" do
          before { visit activate_user_path(user.id, user.confirmation_token) }

          it { should have_title "" }
          it { should have_content("Your account has been activated") }
        end

        describe "with invalid confirmation" do
          before { visit activate_user_path(user.id, "bogus") }

          it { should have_title "" }
          it { should have_content("link is invalid") }
        end

        describe "with expired confirmation" do
          before do
            user.confirmation_sent_at = 3.days.ago
            user.save!
            visit activate_user_path(user.id, user.confirmation_token)
          end

          it { should have_content("link has expired") }
          it { should have_content("email has been sent") }

          it "should send the email" do
            user_updated = User.find_by_email!(user.email)
            last_email.to.should include(user_updated.email)
            last_email.body.should include(user_updated.confirmation_token)
          end
        end

        describe "with already used confirmation" do
          before do
            visit activate_user_path(user.id, user.confirmation_token)
            visit activate_user_path(user.id, user.confirmation_token)
          end

          it { should have_title "" }
          it { should have_content("link is invalid") }
        end

        describe "for an active user" do
          before do
            user.active = true
            user.save!
            visit activate_user_path(user.id, user.confirmation_token)
          end

          it { should have_title "" }
          it { should have_content("link is invalid") }
        end
      end
    end
  end

  describe "scited_papers" do
    let(:user)   { FactoryGirl.create(:user) }
    let(:paper1) { FactoryGirl.create(:paper) }
    let(:paper2) { FactoryGirl.create(:paper) }

    before do
      user.scite!(paper1)
      visit scites_user_path(user)
    end

    it { should have_title "Scites for #{user.name}" }
    it { should have_link paper1.identifier }
    it { should_not have_link paper2.identifier }
  end

  describe "comments" do
    let(:user)       { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:paper1)     { FactoryGirl.create(:paper) }
    let(:paper2)     { FactoryGirl.create(:paper) }
    let(:paper3)     { FactoryGirl.create(:paper) }

    before do
      5.times { |n| user.comments.create(paper_id: paper1.id, content: "Comment #{n+1} on #{paper1.title}") }
      5.times { |n| user.comments.create(paper_id: paper2.id, content: "Comment #{n+1} on #{paper2.title}") }
      5.times { |n| other_user.comments.create(paper_id: paper2.id, content: "Other User's Comment #{n+1} on #{paper2.title}") }
                                             5.times { |n| other_user.comments.create(paper_id: paper3.id, content: "Other User's Comment #{n+1} on #{paper3.title}") }
      visit comments_user_path(user)
    end

    it { should have_title "Comments for #{user.name}" }
    it { should have_content "10 comments" }

    it "should have all the user's comments" do
      user.comments.each do |comment|
        page.should have_content comment.content
      end
    end

    it "should not have comments from other papers" do
      other_user.comments.each do |comment|
        page.should_not have_content comment.content
      end
    end

    it "should link to the papers" do
      user.comments.each do |comment|
        page.should have_link comment.paper.identifier
      end
    end

    it "should list comment time/date" do
      user.comments.each do |comment|
        page.should have_content comment.created_at.to_formatted_s(:short)
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_heading "Edit user" }
      it { should have_title "Edit user" }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      let(:error) { '1 error prohibited this user from being saved' }

      describe "with non-matching password confirmation" do
        before do
          fill_in "Password",     with: user.password+'right'
          fill_in "Confirmation", with: user.password+'wrong'
          fill_in "Old Password", with: user.password
          update
        end

        it { should have_content(error) }
      end

      describe "with incorrect old password" do
        before do
          fill_in "Password",     with: user.password+'new'
          fill_in "Confirmation", with: user.password+'new'
          fill_in "Old Password", with: user.password+'wrong'
          update
        end

        it { should have_content("Old password is incorrect!") }
      end
    end

    describe "with valid information" do
      let(:user)      { FactoryGirl.create(:user) }
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }

      before do
        fill_in "Name",         with: new_name
        fill_in "Email",        with: new_email
        fill_in "Old Password", with: user.password
      end

      describe "with new password" do
        before do
          fill_in "Password",     with: user.password+'new'
          fill_in "Confirmation", with: user.password+'new'
          click_button "Update"
        end

        it { should have_selector('title', text: new_name) }
        it { should have_selector('div.flash.success') }
        specify { user.reload.name.should  == new_name }
        specify { user.reload.email.should == new_email }
      end

      describe "without changing password" do
        before do
          click_button "Update"
        end

        it { should have_selector('title', text: new_name) }
        it { should have_selector('div.flash.success') }
        specify { user.reload.name.should  == new_name }
        specify { user.reload.email.should == new_email }
      end
    end

    describe "email confirmation of address changes" do
      let(:new_name) { "New User" }
      let(:new_email) { "new@example.com" }

      before do
        fill_in "Old Password", with: user.password
      end

      describe "with new email address" do
        before do
          fill_in "Email", with: new_email
          click_button "Update"
        end

        it "should send email to old address" do
          last_email.should_not be_nil
          last_email.to.should include(user.email)
        end
      end

      describe "without new email address" do
        before do
          fill_in "Name", with: new_name
          click_button "Update"
        end

        it "should not send email" do
          last_email.should be_nil
        end
      end
    end
  end
end
