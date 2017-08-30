# frozen_string_literal: true

module HasCreators
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :creators, class_name: 'Person', predicate: ::RDF::Vocab::DC11.creator
    alias_method :creator, :creators

    # TODO: Will this only be used by passing in a hashes of attributes, or is there a case where we want to be able to pass in Person records?
    #
    # {"0"=>{"first_name"=>"Frodo", "last_name"=>"Baggins"}}
    def creators=(values)
      person_records = values.map { |key, attrs| Person.find_or_create(attrs) }
      super(person_records)
    end
  end
end
