# frozen_string_literal: true

FactoryGirl.define do
  factory :collection, aliases: [:public_collection] do
    transient do
      user { FactoryGirl.create(:user) }
      creator { person.build(first_name: 'creatorcreator') }
    end

    sequence(:title)       { |n| ["Title #{n}"] }
    sequence(:description) { |n| ["Description #{n}"] }
  
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    after(:build) do |collection, attrs|
      collection.apply_depositor_metadata((attrs.depositor || attrs.user.user_key))
    end

    factory :my_collection do
      title ['My collection']
      description 'My incredibly detailed description of the collection'
      creators [creator]
    end

    trait :with_complete_metadata do
      creators [creator]
      resource_type ['Dissertation aaa']
      publisher ['publisher bbb']
      contributor ['contrib ccc']
      subject ['subject ddd']
      language ['language fff']
      based_near ['based_near ggg']
      keyword ['keyword hhh']
      rights ['http://creativecommons.org/licenses/by/3.0/us/']
      date_created ['Once upon a time']
      identifier ['112243465']
      related_url ['http://test.com']
    end
  end
end
