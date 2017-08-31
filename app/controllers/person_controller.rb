class PersonController < ApplicationController
  protect_from_forgery with: :null_session

  def all
    render json: Person.all
  end
  
  def first_name_query
    results = Person.all.select { |p| p.first_name.match(/^#{params['q']}/i) }
    render json: results
  end

  def last_name_query
    results = Person.all.select { |p| p.last_name.match(/^#{params['q']}/i) }
    render json: results
  end
end
