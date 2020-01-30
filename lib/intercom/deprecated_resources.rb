# frozen_string_literal: true

module Intercom
  module DeprecatedResources
    def deprecated__leads
      Intercom::Service::Lead.new(self)
    end

    def deprecated__users
      Intercom::Service::User.new(self)
    end
  end
end
