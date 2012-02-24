require 'intercom/intercom_object'

module Intercom
  ##
  # object representing a social profile for the User (see )http://docs.intercom.io/#SocialProfiles)
  class SocialProfile < IntercomObject
    def for_wire #:nodoc:
      @attributes
    end
  end
end
