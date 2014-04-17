require 'spec_helper'

describe Admin::UsersController do
  describe 'routing' do
    describe 'GET /admin/users/:username/edit' do
      specify do
        request = proc { get('/admin/users/neutron/edit') }
        expect(request.call).to route_to('admin/users#edit', username: 'neutron')
      end
    end

    describe 'PATCH /admin/users/:username' do
      specify do
        request = proc { patch('/admin/users/neutron') }
        expect(request.call).to route_to('admin/users#update', username: 'neutron')
      end
    end
  end
end
