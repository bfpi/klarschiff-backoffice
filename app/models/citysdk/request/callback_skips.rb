# frozen_string_literal: true

module Citysdk
  class Request
    module CallbackSkips
      extend ActiveSupport::Concern

      included do
        %i[add_photo update_address_parcel_property_owner reset_archived set_reviewed_at].each do |filter|
          skip_callback :validation, :before, filter
        end
      end
    end
  end
end
