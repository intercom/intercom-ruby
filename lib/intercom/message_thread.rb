require 'intercom/user_resource'

module Intercom
  # A conversation with a user. Either started by the users sending a message to your application using Intercom, or by an Admin sending a message to the user.
  # == Examples
  #
  # Fetching all {MessageThread}'s for a user
  #    message_threads = Intercom::MessageThread.find_all(:email => "bob@example.com")
  #    message_threads.size
  #    message_thread = message_threads[0]
  #
  # Fetching a particular {MessageThread}
  #    message_thread = Intercom::MessageThread.find(:email => "bob@example.com", :thread_id => 123)
  #    message_thread.messages.map{|message| message.html }
  #
  # Creating a {MessageThread} on behalf of a user:
  #    message_thread = Intercom::MessageThread.create(:email => "bob@example.com", :body => "Hello, I need some help....")
  #
  class MessageThread < UserResource
    include UnixTimestampUnwrapper

    # Finds a particular Message identified by thread_id
    # @return [Message]
    def self.find(params)
      requires_parameters(params, %W(thread_id))
      api_response = Intercom.get("users/message_threads", params)
      MessageThread.from_api(api_response)
    end

    # Finds all Messages to show a particular user
    # @return [Array<Message>]
    def self.find_all(params)
      response = Intercom.get("users/message_threads", params)
      response.map { |message| MessageThread.from_api(message) }
    end

    # Either creates a new message from this user to your application admins, or a comment on an existing one
    # @return [Message]
    def self.create(params)
      requires_parameters(params, %W(body))
      MessageThread.new(params).save
    end

    # Marks a message (identified by thread_id) as read
    # @return [Message]
    def self.mark_as_read(params)
      requires_parameters(params, %W(thread_id))
      MessageThread.new({"read" => true}.merge(params)).save(:put)
    end

    # @return [Message]
    def save(method=:post)
      response = Intercom.send(method, "users/message_threads", to_hash)
      self.update_from_api_response(response)
    end

    # @return [Message]
    def mark_as_read!
      Intercom::MessageThread.mark_as_read(:thread_id => thread_id, :email => email)
    end

    # Set the content of the message for new message creation.
    # @param [String] body of the message. Supports markdown syntax
    # @return [String]
    def body=(body)
      @attributes["body"] = body
    end

    # @return [Time] when this {MessageThread} was created
    def created_at
      time_at("created_at")
    end

    # @return [Time] when the last update to this {MessageThread} happened
    def updated_at
      time_at("updated_at")
    end

    # @return [Integer]
    # @param [Integer thread_id]
    def thread_id=(thread_id)
      @attributes["thread_id"] = thread_id
    end

    # @return [Integer]
    def thread_id
      @attributes["thread_id"]
    end

    # @return [Boolean]
    # @param [Boolean] read whether the latest revision of the thread has been read by the user
    def read=(read)
      @attributes["read"] = read
    end

    # @return [Boolean]
    def read
      @attributes["read"]
    end

    # @return [String]
    # @param [String] read the url that was being viewed when the comment was sent
    def url=(url)
      @attributes["url"] = url
    end

    # @return [String]
    def url
      @attributes["url"]
    end

    # @return [Array<Message>]
    def messages
      @attributes["messages"].map {|message_hash| Message.new(message_hash)}
    end
  end

  # a {MessageThread} contains multiple {Message}'s
  #
  # {Message}'s are a read only part of a {MessageThread}
  class Message
    include UnixTimestampUnwrapper

    # Used to create a {Message} from part of the response from the API
    def initialize(params)
      @attributes = params
    end

    # @return [MessageAuthor] Author, which can be either an end user, or an Admin for your application
    def from
      MessageAuthor.new(@attributes["from"])
    end

    # @return [String] html markup for the message
    def html
      @attributes["html"]
    end

    # @return [Time] when this message was posted
    def created_at
      time_at("created_at")
    end
  end

  # each {Message} in a {MessageThread} has a {MessageAuthor}
  #
  # Admin authors have a name, and an avatar_path_50. Non-admin authors have a name, user_id and email.
  class MessageAuthor
    # Used to create a {MessageAuthor} from part of the response from the API
    def initialize(params)
      @attributes = params
    end

    # @return [Boolean] whether this author is an admin or not
    def admin?
      @attributes['is_admin']
    end

    # @return [String] email address of the author (only available when {#admin?} is false)
    def email
      @attributes['email']
    end

    # @return [String] user_id of the author (only available when {#admin?} is false)
    def user_id
      @attributes['user_id']
    end

    # @return [String] url of 50x50 avatar of the admin who posted this message (only available when {#admin?} is true)
    def avatar_path_50
      @attributes['avatar_path_50']
    end

    # @return [String] real name of the Admin/User, when available.
    def name
      @attributes['name']
    end
  end
end
