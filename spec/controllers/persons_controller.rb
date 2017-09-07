# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe PersonsController do
  context 'a logged in user' do
    let(:user) { create(:user, display_name: 'First User') }

    describe 'GET name_search' do
      before do
        login_as user
        request.headers['REMOTE_USER'] = 'user1000'
        p = Person.new(first_name: 'Testing', last_name: 'Person')
        p.save!
      end
      it 'returns JSON search based on the first name & last name' do
        get :name_query, params: { q: 'Testing' }
        results = JSON.parse(response.body)
        expect(results[0]['first_name_tesim']).to eq(['Testing'])
      end
      it 'returns JSON search based on the first name' do
        get :name_query, params: { q: 'Person' }
        results = JSON.parse(response.body)
        expect(results[0]['last_name_tesim']).to eq(['Person'])
      end
    end
  end
end
