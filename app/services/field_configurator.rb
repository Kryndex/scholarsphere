# frozen_string_literal: true
class FieldConfigurator

  class << self

    # Defines what fields are shown on the search index view for each item
    def index_fields
      field_hash([:resource_type, :creator, :keyword, :subject, :language,
                  :based_near, :publisher, :has_model, :date_uploaded])
    end

    # Defines what fields are shown on the work show page
    def search_fields
      field_hash([:resource_type, :creator, :keyword, :subject, :language,
                  :based_near, :publisher, :date_uploaded, :depositor,
                  :contributor, :date_modified, :date_created, :rights,
                  :identifier, :description, :title, :file_format])
    end

    # Defines what fields are shown in the facets on the search index view
    def facet_fields
      field_hash([:resource_type, :creator, :keyword, :subject, :language,
                  :based_near, :publisher, :has_model, :collection, :file_format])
    end

    # Defines what fields are available to the user in the universal search
    def show_fields
      field_hash([:resource_type, :creator, :keyword, :subject, :language,
                       :based_near, :publisher, :date_uploaded, :depositor,
                       :contributor, :date_modified, :date_created, :rights,
                       :identifier, :description])
    end

    private

      def field_hash(keys)
        fields = {}
        all_fields.each do |field_config|
          if keys.include?(field_config.key)
            fields[field_config.key] = field_config
          end
        end
        fields
      end

      def all_fields
        [ FieldConfig.new(:resource_type),
          FieldConfig.new(:creator, facet_cleaners: [:titleize]),
          FieldConfig.new(:keyword, facet_cleaners: [:downcase]),
          FieldConfig.new(:subject),
          FieldConfig.new(:language),
          FieldConfig.new(:based_near),
          FieldConfig.new(:publisher, facet_cleaners: [:titleize]),
          FieldConfig.new(:has_model, label: "Object Type",
                          helper_method: :titleize,
                          index_solr_type: :symbol, solr_type: :symbol),
          FieldConfig.new(:date_uploaded, index_solr_type: :stored_sortable,
                          index_type: :date),
          FieldConfig.new(:collection, helper_method: :collection_helper_method),
          FieldConfig.new(:file_format),
          FieldConfig.new(:date_uploaded,
                        index_solr_type: :stored_sortable,
                        index_type: :date),
          FieldConfig.new(:depositor),
          FieldConfig.new(:contributor),
          FieldConfig.new(:date_modified,
                            index_solr_type: :stored_sortable,
                            index_type: :date),
          FieldConfig.new(:date_created),
          FieldConfig.new(:rights),
          FieldConfig.new(:identifier),
          FieldConfig.new(:description),
          FieldConfig.new(:title),
          FieldConfig.new(:file_format)
        ]
      end
  end
end
