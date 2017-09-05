# frozen_string_literal: true

module WithCreator
  extend ActiveSupport::Concern

  def creators
    model.creators.build if model.creators.blank?
    model.creators.to_a
  end

  included do
    def self.build_permitted_params
      permitted = super
      permitted << { creators: [:id, :first_name, :last_name, :_destroy] }
      permitted
    end
  end
end
