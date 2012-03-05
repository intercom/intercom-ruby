require 'intercom/user_resource'

module Intercom
  ##
  # object representing a conversation with a user
  class MessageThread < UserResource
    include UnixTimestampUnwrapper

    ##
    # Finds a particular Message identified by thread_id
    def self.find(params)
      requires_parameters(params, %W(thread_id))
      api_response = Intercom.get("users/message_threads", params)
      MessageThread.from_api(api_response)
    end

    ##
    # Finds all Messages to show a particular user
    def self.find_all(params)
      response = Intercom.get("users/message_threads", params)
      response.map { |message| MessageThread.from_api(message) }
    end

    ##
    # Either creates a new message from this user to your application admins, or a comment on an existing one
    def self.create(params)
      requires_parameters(params, %W(body))
      MessageThread.new(params).save
    end

    ##
    # Marks a message (identified by thread_id) as read
    def self.mark_as_read(params)
      requires_parameters(params, %W(thread_id))
      MessageThread.new({"read" => true}.merge(params)).save(:put)
    end

    def save(method=:post)
      response = Intercom.send(method, "users/message_threads", to_hash)
      self.update_from_api_response(response)
    end

    ##
    # Set the content of the message. Supports standard markdown syntax
    def body=(body)
      @attributes["body"] = body
    end

    def body
      @attributes["body"]
    end

    def created_at
      time_at("created_at")
    end

    def updated_at
      time_at("updated_at")
    end


    def thread_id=(thread_id)
      @attributes["thread_id"] = thread_id
    end

    def thread_id
      @attributes["thread_id"]
    end

    def read=(read)
      @attributes["read"] = read
    end

    def read
      @attributes["read"]
    end

    def messages
      @attributes["messages"].map {|message_hash| Message.new(message_hash)}
    end
  end

  class Message
    include UnixTimestampUnwrapper

    def initialize(params)
      @attributes = params
    end

    def from
      MessageAuthor.new(@attributes["from"])
    end

    def html
      @attributes["html"]
    end

    def created_at
      time_at("created_at")
    end
  end

  class MessageAuthor
    def initialize(params)
      @attributes = params
    end

    def admin?
      @attributes['is_admin']
    end

    def email
      @attributes['email']
    end

    def user_id
      @attributes['user_id']
    end

    def avatar_path_50
      @attributes['avatar_path_50']
    end

    def name
      @attributes['name']
    end
  end
end
