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

    # Testing HTML
    context 'when params[:id] contains versioning' do
      before { get :show, params: { paper_uid: "#{paper.uid}v1" } }

      specify do
        expect(assigns(:paper).uid).to eq paper.uid
        expect(response.response_code).to eq 200
        expect(response).to render_template('papers/show')
      end
    end

    # Testing JSON 
    context 'when requesting JSON' do
      before { get :show, params: { paper_uid: paper.uid }, format: :json }

      it 'returns a successful JSON response' do
        expect(response.response_code).to eq 200
        expect(response.content_type).to include 'application/json'
        
        json = JSON.parse(response.body)
        expect(json['uid']).to eq paper.uid
        expect(json['title']).to eq paper.title
        expect(json).to have_key('scites_count')
        expect(json).to have_key('is_scited')
      end
    end
  end
end
