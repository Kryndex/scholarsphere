# frozen_string_literal: true

require Sufia::Engine.root.to_s + '/app/models/batch_upload_item.rb'

class BatchUploadItem < ActiveFedora::Base
  # Re-open this class from Sufia so that we can add the 'creators=' method
  include HasCreators
end
