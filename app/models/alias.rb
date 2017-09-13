# frozen_string_literal: true

class Alias < ActiveFedora::Base
  include Hydra::PCDM::ObjectBehavior

  belongs_to :person, class_name: 'Person', predicate: ::RDF::Vocab::FOAF.name

  property :display_name, predicate: ::RDF::Vocab::FOAF.nick, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  # If ID exists, match on ID, else try to match name
  def self.find_or_create(attributes)
    attributes = attributes.with_indifferent_access
    attributes.delete(:id) if attributes[:id].blank?
    query_attrs = if attributes[:id].blank?
                    { display_name_ssim: attributes[:display_name] }
                  else
                    { id: attributes[:id] }
                  end
    person = Alias.where(query_attrs).limit(1).first
    person ||= Alias.create(attributes)
    person
  end
end
