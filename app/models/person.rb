# frozen_string_literal: true

class Person < ActiveFedora::Base
  property :first_name, predicate: ::RDF::Vocab::FOAF.firstName, multiple: false do |index|
    index.as :stored_searchable
  end

  property :last_name, predicate: ::RDF::Vocab::FOAF.lastName, multiple: false do |index|
    index.as :stored_searchable
  end

  def self.find_or_create(attributes)
    attributes = attributes.with_indifferent_access
    query_attrs = if attributes[:id].blank?
                    {
                      first_name_tesim: attributes[:first_name],
                      last_name_tesim: attributes[:last_name]
                      # TODO: Match middle initial too?
                    }
                  else
                    { id: attributes[:id] }
                  end
    person = Person.where(query_attrs).limit(1).first
    person ||= Person.create(attributes)
    person
  end
end
