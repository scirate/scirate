require 'spec_helper'

describe FeedsController do
  let!(:user) { FactoryGirl.create(:user) }
  before { become user }

  describe 'GET index' do

    # Testing JSON
    context 'when requesting JSON' do
      before { get :index, format: :json }

      it 'returns a list of papers' do
        expect(response.response_code).to eq 200
        json = JSON.parse(response.body)
        expect(json).to have_key('papers')
        expect(json).to have_key('date')
      end
    end
  end
end
