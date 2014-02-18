require 'intercom/requires_parameters'
require 'intercom/hashable_object'


module Intercom
  
  ##
  # Represents a User Event
  #
  # A user event consists of an event_name and a user the event applies to. The user is identified via email or id.
  # Optionally, a created timestamp may be supplied.
  #
  # == Examples
  #
  #  user_event = Intercom::UserEvent.create(:event_name => "funkratic", :created => Time.now, :company_id: "6", :user => current_user)
  #
  #  You can also create an user-event and save it like this:
  #  user_event = Intercom::UserEvent.new
  #  user_event.event_name = "funkratic"
  #  user_event.created = Time.now
  #  user_event.user = current_user
  #  user_event.save
  #
  # == Batch
  #
  # User events can be created in batches, and sent as one request. To do some, create user events
  # without calling .create, as follows:
  # 
  # user_event = Intercom::UserEvent.new
  # user_event.event_name = "funkratic"
  # user_event.user = current_user
  #
  # Then pass them to the save_batch_events class method, along with an (optional) default user:
  #
  # Intercom::UserEvent.save_batch_events(events, default_user)
  #
  # Any events without a user will be assigned to the default_user.
  
  class UserEvent
    extend RequiresParameters
    include HashableObject
    
    attr_accessor :event_name, :user, :created # required
    attr_accessor :metadata, :type
    
    def initialize(attributes={})
      from_hash(attributes)
    end
    
    ##
    # Creates a new User Event using params and saves it
    # @see #save
    def self.create(params)
      params[:created] ||= Time.now
      requires_parameters(params, %W(event_name user created))
      UserEvent.new(params).save
    end
        
    ##
    # Save the User Event
    def save
      raise ArgumentError.new("Missing User") if user.nil?
      UserEvent.save_batch_events([self])
      self
    end
    
    ##
    # Save a list of User Events, with an optional base_user
    def self.save_batch_events(events, base_user=nil)
      hash = { :type => 'event.list', :data => []}
      hash[:user] = { :user_id => base_user.user_id } if base_user
      events.each do |event|
        hash[:data] << event.event_hash
      end
      post_to_intercom(hash)
    end

    def self.post_to_intercom(hash)
      Intercom.post('/events', hash)
    end
        
    def user_hash
      { :user_id => user.user_id }
    end
    
    def event_hash
      event = { :event_name => event_name, :created => created.to_i }
      event[:type] = type unless type.nil?
      event[:user] = user_hash unless user.nil?
      event[:metadata] = metadata unless metadata.nil?
      event
    end
  end
end
