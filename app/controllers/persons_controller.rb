# frozen_string_literal: true

class PersonsController < ApplicationController
  protect_from_forgery with: :null_session

  def name_query
    query = "has_model_ssim:Person AND first_name_tesim:${params['q'}* OR last_name_tesim:${params['q']}*"
    render json: ActiveFedora::SolrService.query(query)
  end
end
