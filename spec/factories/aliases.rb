# frozen_string_literal: true

FactoryGirl.define do
  factory :alias do
    sequence(:display_name) { |n| "Display Name #{n}" }
  end
end
