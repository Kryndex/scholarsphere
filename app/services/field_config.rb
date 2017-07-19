# frozen_string_literal: true
class FieldConfig
  attr_reader :label, :opts, :key
  def initialize(key, opts={ })
    @opts = opts
    @key = key

    if opts[:label].blank?
      @label = key.to_s.titleize
      @opts[:label] = @label
    else
      @label = opts[:label]
    end

    @opts[:solr_type] ||= :facetable
  end
end
