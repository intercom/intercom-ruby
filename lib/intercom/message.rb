require 'intercom/intercom_object'

module Intercom
  ##
  # object representing a Message (+ any conversation on it) with a user
  class Message < IntercomObject

    ##
    # Finds a particular Message identified by thread_id
    def self.find(params)
      requires_parameters(params, %W(thread_id))
      Message.new(Intercom.get("messages", params))
    end

    ##
    # Finds all Messages to show a particular user
    def self.find_all(params)
      allows_parameters(params, [])
      response = Intercom.get("messages", params)
      response.map { |message| Message.new(message) }
    end

    ##
    # Either creates a new message from this user to your application admins, or a comment on an existing one
    def self.create(params)
      allows_parameters(params, %W(thread_id body))
      requires_parameters(params, %W(body))
      Message.new(Intercom.post("messages", params))
    end

    ##
    # Marks a message (identified by thread_id) as read
    def self.mark_as_read(params)
      requires_parameters(params, %W(thread_id))
      Message.new(Intercom.put("messages", {"read" => true}.merge(params)))
    end
  end
end
