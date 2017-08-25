# frozen_string_literal: true

class WorkIndexer < Sufia::WorkIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      index_creator(solr_doc)
      solr_doc[Solrizer.solr_name('file_set_ids', :symbol)] = solr_doc[Solrizer.solr_name('member_ids', :symbol)]
      solr_doc[Solrizer.solr_name('resource_type', :facetable)] = object.resource_type
      solr_doc[Solrizer.solr_name('file_format', :stored_searchable)] = representative.file_format
      solr_doc[Solrizer.solr_name('file_format', :facetable)] = representative.file_format
      solr_doc[Solrizer.solr_name(:bytes, CurationConcerns::CollectionIndexer::STORED_LONG)] = object.bytes
      SolrDocumentGroomer.call(solr_doc)
    end
  end

  private

    def index_creator(solr_doc)
      creator_names = object.creators.map do |creator|
        first = creator.first_name
        first = nil if first.blank?
        last = creator.last_name
        last = nil if last.blank?
        [first, last].compact.join(' ')
      end

      solr_doc[Solrizer.solr_name('creator', :facetable)] = creator_names
      solr_doc[Solrizer.solr_name('creator', :stored_searchable)] = creator_names
    end

    def representative
      object.representative || NullRepresentative.new
    end

    # Use the naught gem if this gets bigger
    class NullRepresentative
      def file_format
        nil
      end
    end
end
