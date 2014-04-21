require 'spec_helper'

describe Admin::UsersController do
  let!(:admin) { FactoryGirl.create(:admin) }
  let!(:user) {
    FactoryGirl.create(:user, fullname: 'Foobar', username: 'foo', email: 'foo@bar.io')
  }

  describe 'when login as non-admin user' do
    before { sign_in user }

    describe 'GET edit' do
      before { get :edit, username: user.username }

      specify do
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq "You don't have permission to do that!"
      end
    end

    describe 'PATCH update' do
      before { patch :edit, username: user.username, user: {} }

      specify do
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq "You don't have permission to do that!"
      end
    end
  end

  describe 'when login as admin user' do
    before { sign_in admin }

    describe 'GET edit' do
      before { get :edit, username: user.username }

      specify do
        expect(response.response_code).to eq 200
        expect(response).to render_template('admin/users/edit')
        expect(assigns(:user)).to eq user
      end
    end

    describe 'PATCH update' do
      context 'when user is successfully updated' do
        before do
          patch :update, username: user.username, user: {
            fullname: 'Lorem',
            username: 'lorem',
            email:    'foo@bar.io',
            account_status: User::STATUS_MODERATOR
          }
        end

        specify do
          expect(response.response_code).to eq 200
          expect(response).to render_template('admin/users/edit')
          expect(flash[:success]).to eq 'User has been successfully updated.'
          expect(assigns(:user)).to eq user

          user.reload

          expect(user.fullname).to eq 'Lorem'
          expect(user.username).to eq 'lorem'
          expect(user.email).to eq 'foo@bar.io'
          expect(user.account_status).to eq User::STATUS_MODERATOR
        end
      end

      context 'when updating with new email' do
        before do
          expect_any_instance_of(User).to receive(:send_email_change_confirmation).once
          patch :update, username: user.username, user: { email: 'bar@foo.io' }
        end

        specify do
          expect(response.response_code).to eq 200
          expect(response).to render_template('admin/users/edit')
          expect(flash[:success]).to eq 'User has been successfully updated.'
          expect(assigns(:user)).to eq user

          user.reload

          expect(user.email).to eq 'bar@foo.io'
        end
      end

      context 'when user is failed to be upated' do
        before do
          allow_any_instance_of(User).to receive(:update).and_return(false)
          patch :update, username: user.username, user: {
            fullname: 'Lorem',
            username: 'lorem',
            email:    'foo@bar.io',
            account_status: User::STATUS_MODERATOR
          }
        end

        specify do
          expect(response.response_code).to eq 200
          expect(response).to render_template('admin/users/edit')
          expect(flash[:error]).to eq 'Failed to update user.'
          expect(assigns(:user)).to eq user

          user.reload

          expect(user.fullname).to eq 'Foobar'
          expect(user.username).to eq 'foo'
          expect(user.email).to eq 'foo@bar.io'
          expect(user.account_status).to eq User::STATUS_USER
        end
      end
    end
  end

end