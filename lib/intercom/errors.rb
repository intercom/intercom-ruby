module Intercom

  # Base class exception from which all public Intercom exceptions will be derived
  class IntercomError < StandardError
    attr_reader :http_code, :application_error_code, :field, :request_id
    def initialize(message, context={})
      @http_code = context[:http_code]
      @application_error_code = context[:application_error_code]
      @field = context[:field]
      @request_id = context[:request_id]
      super(message)
    end
    def inspect
      attributes = instance_variables.map do |var|
        value = instance_variable_get(var).inspect
        "#{var}=#{value}"
      end
      "##{self.class.name}:#{message} #{attributes.join(' ')}"
    end
    def to_hash
      {message: message}
        .merge(Hash[instance_variables.map{ |var| [var[1..-1], instance_variable_get(var)] }])
    end
  end

  # Raised when the token you provided is incorrect or not authorized to access certain type of data.
  # Check that you have set Intercom.token correctly.
  class AuthenticationError < IntercomError; end

  # Raised when the token provided is linked to a deleted application.
  class AppSuspendedError < AuthenticationError; end

  # Raised when the token provided has been revoked.
  class TokenRevokedError < AuthenticationError; end

  # Raised when the token provided can't be decoded, and is most likely invalid.
  class TokenUnauthorizedError < AuthenticationError; end

  # Raised when something goes wrong on within the Intercom API service.
  class ServerError < IntercomError; end

  # Raised when we have bad gateway errors.
  class BadGatewayError < IntercomError; end

  # Raised when we experience a socket read timeout
  class ServiceUnavailableError < IntercomError; end

  # Raised when we experience socket connect timeout
  class ServiceConnectionError < IntercomError; end

  # Raised when requesting resources on behalf of a user that doesn't exist in your application on Intercom.
  class ResourceNotFound < IntercomError; end

  # Raised when requesting an admin that doesn't exist in your Intercom workspace.
  class AdminNotFound < IntercomError; end

  # Raised when trying to create a resource that already exists in Intercom.
  class ResourceNotUniqueError < IntercomError; end

  # Raised when the request has bad syntax
  class BadRequestError < IntercomError; end

  # Raised when you have exceeded the API rate limit
  class RateLimitExceeded < IntercomError; end

  # Raised when the request throws an error not accounted for
  class UnexpectedError < IntercomError; end

  # Raised when the CDA limit for the app has been reached
  class CDALimitReachedError < IntercomError; end

  # Raised when multiple users match the query (typically duplicate email addresses)
  class MultipleMatchingUsersError < IntercomError; end

  # Raised when restoring a blocked user
  class BlockedUserError < IntercomError; end

  # Raised when you try to call a non-setter method that does not exist on an object
  class Intercom::AttributeNotSetError < IntercomError; end

  # Raised when unexpected nil returned from server
  class Intercom::HttpError < IntercomError; end

  # Raised when an invalid api version is used
  class ApiVersionInvalid < IntercomError; end

  # Raised when an creating a scroll if one already exists
  class ScrollAlreadyExistsError < IntercomError; end

  #
  # Non-public errors (internal to the gem)
  #

  # Base class exception from which all private Intercom exceptions will be derived
  class IntercomInternalError < StandardError; end

  # Raised when we attempt to handle a method missing but are unsuccessful
  class Intercom::NoMethodMissingHandler < IntercomInternalError; end

  class Intercom::DeserializationError < IntercomInternalError; end

end
