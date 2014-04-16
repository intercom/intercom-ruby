require 'intercom/requires_parameters'
require 'intercom/hashable_object'


module Intercom
  
  ##
  # Represents an Event
  #
  # An event consists of an event_name and a user the event applies to. The user is identified via email or id.
  # Additionally, a created timestamp is required.
  #
  # == Examples
  #
  #  event = Intercom::Event.create(:event_name => "post", :user => current_user, :created_at => Time.now)
  #
  #  You can also create an user-event and save it like this:
  #  event = Intercom::Event.new
  #  event.event_name = "publish-post"
  #  event.user = current_user
  #  event.created_at = Time.now
  #  event.metadata = {
  #   :title => 'Gravity Review',
  #   :link => 'https://example.org/posts/22',
  #   :comments => 'https://example.org/posts/22/comments'
  # }
  #  event.save
  #
  # == Batch
  #
  # Events can be created in batches, and sent as one request. To do some, create events
  # without calling .create, as follows:
  # 
  # event = Intercom::Event.new
  # event.event_name = "publish-post"
  # event.user = current_user
  #
  # Then pass them to the save_batch_events class method, along with an (optional) default user:
  #
  # Intercom::Event.save_batch_events(events, default_user)
  #
  # Any events without a user will be assigned to the default_user.
  #
  # Note: if you do not supply a created time, the current time in UTC will be used. Events that have the same 
  # user, name, and created time (to second granularity) may be treated as duplicates by the server.
  
  class Event
    extend RequiresParameters
    include HashableObject
    
    attr_accessor :event_name, :user, :created_at # required
    attr_accessor :metadata, :type
    
    def initialize(attributes={})
      from_hash(attributes)
    end
    
    ##
    # Creates a new Event using params and saves it
    # @see #save
    def self.create(params)
      params[:created_at] ||= Time.now
      requires_parameters(params, %W(event_name user created_at))
      Event.new(params).save
    end
        
    ##
    # Save the Event
    def save
      raise ArgumentError.new("Missing User") if user.nil?
      Event.save_batch_events([self])
      self
    end
    
    ##
    # Save a list of Events, with an optional base_user
    def self.save_batch_events(events, base_user=nil)
      hash = { :type => 'event.list', :data => []}
      hash[:user] = user_hash(base_user) if base_user
      events.each do |event|
        hash[:data] << event.event_hash
      end
      post_to_intercom(hash)
    end
    
    def self.user_hash(user)
      user.user_id ? { :user_id => user.user_id } : { :email => user.email }
    end

    def self.post_to_intercom(hash)
      Intercom.post('/events', hash)
    end
        
    def user_hash
      Event.user_hash(user)
    end
    
    def event_hash
      event = { :event_name => event_name, :created => created_at.nil? ?  Time.now.utc.to_i : created_at.to_i }
      event[:type] = type.nil? ? 'event' : type
      event[:user] = user_hash unless user.nil?
      event[:metadata] = metadata unless metadata.nil?
      event
    end
  end
end
