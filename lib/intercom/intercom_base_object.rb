require 'intercom/requires_parameters'
require 'intercom/hashable_object'

module Intercom

  class IntercomBaseObject
    extend RequiresParameters
    include HashableObject

    def initialize(attributes={})
      from_hash(attributes)
    end

    ##
    # Fetch an Object
    def self.from_api(api_response)
      object = self.new
      object.from_hash(api_response)
      object.displayable_self
    end

    ##
    # Creates a new Object using params and saves it
    # @see #save
    def self.create(params)
      requires_parameters(params, self::REQUIRED_PARAMS)
      self.new(params).save
    end

    ##
    # Saves an Object
    def save
      response = Intercom.post(self.class::ENDPOINT, to_wire)
      self.from_hash(response)
      displayable_self
    end

    ##
    # Create a new clean instance to return (only showing the readable attributes)
    def displayable_self
      self.class.new(displayable_attributes)
    end

  end

end