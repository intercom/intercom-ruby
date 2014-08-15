module Intercom

  # Base class exception from which all public Intercom exceptions will be derived
  class IntercomError < StandardError
    attr_reader :http_code, :application_error_code
    def initialize(message, http_code = nil, application_error_code = application_error_code)
      @http_code = http_code
      @application_error_code = application_error_code
      super(message)
    end
  end

  # Raised when the credentials you provide don't match a valid account on Intercom.
  # Check that you have set <b>Intercom.app_id=</b> and <b>Intercom.app_api_key=</b> correctly.
  class AuthenticationError < IntercomError; end

  # Raised when something does wrong on within the Intercom API service.
  class ServerError < IntercomError; end

  # Raised when we have bad gateway errors.
  class BadGatewayError < IntercomError; end

  # Raised when we reach socket connect timeout
  class ServiceUnavailableError < IntercomError; end

  # Raised when requesting resources on behalf of a user that doesn't exist in your application on Intercom.
  class ResourceNotFound < IntercomError; end

  # Raised when the request has a bad syntax
  class BadRequestError < IntercomError; end

  # Raised when you have exceed the API rate limit
  class RateLimitExceeded < IntercomError; end

  # Raised when the request throws an error not accounted for
  class UnexpectedError < IntercomError; end

  # Raised when you try to call a non-setter method that does not exist on an object
  class Intercom::AttributeNotSetError < IntercomError ; end

  #
  # Non-public errors (internal to the gem)
  #

  # Base class exception from which all public Intercom exceptions will be derived
  class IntercomInternalError < StandardError; end

  # Raised when we attempt to handle a method missing but are unsuccessful
  class Intercom::NoMethodMissingHandler < IntercomInternalError; end

  class Intercom::DeserializationError < IntercomInternalError; end
end
