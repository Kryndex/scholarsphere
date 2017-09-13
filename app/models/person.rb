# frozen_string_literal: true

class Person < ActiveFedora::Base
  has_many :aliases

  property :given_name, predicate: ::RDF::Vocab::FOAF.firstName, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  property :sur_name, predicate: ::RDF::Vocab::FOAF.lastName, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  # @todo This may no longer be relevant now that Alias is linked to GenericWork
  # If ID exists, match on ID, else try to match name
  def self.find_or_create(attributes)
    attributes = attributes.with_indifferent_access
    attributes.delete(:id) if attributes[:id].blank?
    query_attrs = if attributes[:id].blank?
                    {
                      given_name_ssim: attributes[:given_name],
                      sur_name_ssim: attributes[:sur_name]
                    }
                  else
                    { id: attributes[:id] }
                  end
    person = Person.where(query_attrs).limit(1).first
    person ||= Person.create(attributes)
    person
  end
end
