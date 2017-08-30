# frozen_string_literal: true

# Changes the behavior of BaseActor#apply_save_data_to_curation_concern to re-assign the depositor
# based if the user is depositing on behalf of someone else.
#
# Additionally, this actor sets the title and creator (again) because this preserves the order. It is
# not exactly clear why this happens, but it is a temporary solution until #948 and #949 are addressed.
module CurationConcerns
  module Actors
    class GenericWorkActor < CurationConcerns::Actors::BaseActor
      def create(attributes)
# 999        attributes['creators'] = ordered_creators(attributes)
        preserve_title_and_creator_order(attributes)
        super
      end

      protected

        # TODO: After we get the auto-suggest lookup working in
        # the form, then we'll need to change this code to look
        # up existing Person records by ID.
        def ordered_creators(attributes)
          ordered_creator_attributes(attributes).reduce([]) do |creators, attrs|
            creators << if attrs[:id].blank?
                          Person.create(attrs)
                        else
                          Person.find(attrs[:id])
                        end
          end
        end

        # Sort the list of creators attributes in order by the
        # hash key that was passed in by the form.  See the spec
        # for an example of how the hash is expected to look.
        def ordered_creator_attributes(attributes)
          return [] unless attributes[:creators]
          ordered_keys = attributes[:creators].keys.map(&:to_i).sort
          ordered_keys.map { |k| attributes[:creators][k.to_s] }
        end

        # Remove this method once #948 and #949 are resolved.
        def preserve_title_and_creator_order(attributes)
          curation_concern.creators = attributes[:creators]
          curation_concern.save
          curation_concern.title = attributes[:title]
        end

        # Overrides CurationConcerns::Actors::BaseActor to reassign the depositor
        # if the user is depositing on behalf of someone else.
        def apply_save_data_to_curation_concern(attributes)
          if attributes.fetch('on_behalf_of', nil).present?
            depositor = ::User.find_by_user_key(attributes.fetch('on_behalf_of'))
            curation_concern.apply_depositor_metadata(depositor)
            curation_concern.edit_users += [depositor, user.user_key]
          end
          super
        end
    end
  end
end
