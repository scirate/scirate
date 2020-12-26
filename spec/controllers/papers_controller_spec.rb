require 'spec_helper'

describe PapersController do
  let!(:paper) { FactoryGirl.create(:paper) }
  let!(:user) { FactoryGirl.create(:user) }
  before { become user }

  describe 'GET show' do
    before { get :show, params: { paper_uid: paper.uid } }

    specify do
      expect(assigns(:paper).uid).to eq paper.uid
      expect(response.response_code).to eq 200
      expect(response).to render_template('papers/show')
    end

    context 'when params[:id] contains versioning' do
      before { get :show, params: { paper_uid: "#{paper.uid}v1" } }

      specify do
        expect(assigns(:paper).uid).to eq paper.uid
        expect(response.response_code).to eq 200
        expect(response).to render_template('papers/show')
      end
    end
  end
end
