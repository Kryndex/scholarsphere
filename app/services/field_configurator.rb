# frozen_string_literal: true
class FieldConfigurator

  class << self

    # Defines what fields are shown on the search index view for each item
    def index_fields
      get_fields([:has_model, :date_uploaded])
    end

    # Defines what fields are shown on the work show page
    def show_fields
      get_fields([:date_uploaded, :depositor, :contributor,
                         :date_modified, :date_created, :rights,
                         :identifier, :description])
    end

    # Defines what fields are shown in the facets on the search index view
    def facet_fields
      get_fields([:has_model, :collection, :file_format])
    end

    # Defines what fields are available to the user in the universal search
    def search_fields
      get_fields([:date_uploaded, :depositor, :contributor,
                           :date_modified, :date_created, :rights,
                           :identifier, :description, :title, :file_format])
    end

    private

      def get_fields(type_specific_fields)
        {
            resource_type: FieldConfig.new("Resource Type"),
            creator: FieldConfig.new(label: "Creator", facet_cleaners: [:titleize]),
            keyword:  FieldConfig.new(label: "Keyword", facet_cleaners: [:downcase]),
            subject: FieldConfig.new("Subject"),
            language: FieldConfig.new("Language"),
            based_near: FieldConfig.new("Location"),
            publisher: FieldConfig.new(label: "Publisher", facet_cleaners: [:titleize]),
        }.merge(all_type_specific_fields.select{|k,v| type_specific_fields.include?(k)})
      end

      def all_type_specific_fields
        {
            has_model:     FieldConfig.new(label: "Object Type",
                                       helper_method: :titleize,
                                       index_solr_type: :symbol,
                                       solr_type: :symbol),
            date_uploaded: FieldConfig.new(label: "Date Uploaded",
                            index_solr_type: :stored_sortable,
                            index_type: :date),
            collection:    FieldConfig.new(label: "Collection", helper_method: :collection_helper_method),
            file_format:   FieldConfig.new("File Format"),
            depositor:  FieldConfig.new("Depositor"),
            contributor: FieldConfig.new("Contributor"),
            date_modified: FieldConfig.new(label: "Date Modified",
                                           index_solr_type: :stored_sortable,
                                           index_type: :date),
            date_created: FieldConfig.new("Date Created"),
            rights: FieldConfig.new("Rights"),
            identifier: FieldConfig.new("Identifier"),
            description: FieldConfig.new("Description"),
            title: FieldConfig.new("Title")
        }
      end
  end
end
