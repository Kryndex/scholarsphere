# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Create a Generic Work with multiple Creators', :clean, js: true do
  context 'a logged in user' do
    let(:user) { create(:user, display_name: 'First User') }
    let(:name) { 'Testing' }
    let(:ldap_fields) { %i[uid givenname sn mail eduPersonPrimaryAffiliation displayname] }

    let(:response) do
      resp1 = format_name_response('cjs999', 'TESTING 3', 'CHRIS')
      resp2 = format_name_response('cjs998', 'TESTING 2', 'CHRIS')
      resp3 = format_name_response('cjs997', 'TESTING 1', 'CHRIS')
      resp4 = format_name_response('utstrans', 'TESTING TRANSFR', 'UNIV')

      resp1 + resp2 + resp3 + resp4
    end

    before do
      login_as user
      p = Agent.create(given_name: 'Testing', sur_name: 'Person', email: 'person@email.com', psu_id: 'tp01')
      create(:alias, display_name: 'Testing Person', agent: p)
    end

    it do
      expect_ldap(:query_ldap_by_name, response, 'TESTING', '*', ldap_fields)

      expect_ldap(:query_ldap_by_mail, response, 'Testing@psu.edu', ldap_fields)
      visit '/concern/generic_works/new'
      # Adding a blank creator field
      click_button 'add-creator'
      click_button 'add-creator'
      expect(page).to have_selector('.creator_inputs', count: 3)

      # Remove a creator field
      execute_script("$('.remove-creator')[0].click()")
      expect(page).to have_selector('.creator_inputs', count: 2)

      # Autocomplete returns a result from Agents
      page.execute_script "$('#find_creator').unbind('blur')"
      fill_in('Find Creator', with: 'Testing')
      expect(page).to have_selector('.tt-suggestion')

      # Add creator field from autocomplete results
      page.execute_script('$(".tt-suggestion").click()')
      expect(page).to have_selector('.creator_inputs', count: 7)
      expect(page).to have_field('generic_work[creators][2][given_name]', readonly: true)
      expect(page).to have_field('generic_work[creators][2][sur_name]', readonly: true)
      expect(page).to have_field('generic_work[creators][2][email]', readonly: true)
      expect(page).to have_field('generic_work[creators][2][psu_id]', readonly: true)
      expect(page).to have_selector("input[value='Testing Person']")
      expect(page).to have_selector("input[value='TESTING TRANSFR UNIV']")
      expect(page).to have_selector("input[value='TESTING 1 CHRIS']")
      expect(page).to have_selector("input[value='TESTING 2 CHRIS']")
      expect(page).to have_selector("input[value='TESTING 3 CHRIS']")

      # Remove the autocompleted creator field
      execute_script("$('.remove-creator')[2].click()")
      expect(page).to have_selector('.creator_inputs', count: 6)
    end
  end
end
