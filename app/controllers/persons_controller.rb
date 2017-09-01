# frozen_string_literal: true

class PersonsController < ApplicationController
  protect_from_forgery with: :null_session

  def all
    render json: Person.where('id:*').limit(Person.count)
  end
end
