module Intercom

  ##
  # Represents a users interaction with your app (eg page view, or using a particular feature)
  #
  # An impressions contains user_ip, user_agent and location.
  #
  # == Examples
  #
  #  impression = Intercom::Impression.create(:email => "person@example.com", :location => "/pricing/upgrade",
  #                                           :user_ip => '1.2.3.4', :user_agent => "my-service-iphone-app-1.2")
  # The impression response will contain {#unread_messages}
  #  impression.unread_messages
  # You can also create an impression and save it like this:
  #  impression = Intercom::Impression.new
  #  impression.email = "person@example.com"
  #  impression.location = "person@example.com"
  #  ....
  #  impression.save
  class Impression < IntercomBaseObject

    ENDPOINT = "/v1/users/impressions"
    REQUIRED_PARAMS = []

    attr_accessor :user_ip, :location, :user_agent
    attr_reader :unread_messages
    attr_writer :user_id, :email

    ##
    # user_ip
    # Set the ip address of the user for this impression

    ##
    # location
    # Set the location in your application that this impression occurred. E.g. the url in a web app, or perhaps the screen in a desktop or phone application.

    ##
    # user_agent
    # Set the user agent of the user this impression (E.g. their browser user agent, or the name and version of a desktop or phone application)

    ##
    # For convenience, after saving, the unread_messages count will be updated with the number of unread messages for the user for their current location.
    #
    # Remember, Auto Messages (http://docs.intercom.io/#AutoMessages) can be targeted to only show when a user views a particular page in your application.
  end
end
