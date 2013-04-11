require 'intercom/requires_parameters'
require 'intercom/hashable_object'

module Intercom

  ##
  # Represents a tag
  #
  # A tag consists of a name, and (optionally) a color and users that you would like to tag. Returns details about the tag and a count of the number of users currently tagged.
  #
  # == Examples
  #
  #  tag = Intercom::Tag.create(:name => "Super Tag", :color => "red", :user_ids => ['abc123', 'def456'])
  #  tag = Intercom::Tag.create(:name => "Super Tag", :color => "red", :emails => ['bob@example.com', 'joe@example.com'])
  #
  #  You can also create a tag and save it like this:
  #  tag = Intercom::Tag.new
  #  tag.name = "Super Tag"
  #  tag.color = "red"
  #  tag.user_ids = ['abc123', 'def456']
  #  tag.tag_or_untag = "tag"
  #  tag.save
  #
  #  Or update a tag and save it like this:
  #  tag = Intercom::Tag.find_by_name "Super Tag"
  #  tag.color = "green"
  #  tag.user_ids = ['abc123']
  #  tag.tag_or_untag = "untag"
  #  tag.save

  class Tag
    extend RequiresParameters
    include HashableObject

    attr_accessor :name, :color
    attr_reader :segment, :tagged_user_count, :id
    attr_writer :user_ids, :emails, :tag_or_untag

    def initialize(attributes={})
      from_hash(attributes)
    end

    ##
    # Finds a Tag using params
    def self.find(params)
      response = Intercom.get("/v1/tags", params)
      from_api(response)
    end

    def self.from_api(api_response)
      tag = Tag.new
      tag.from_hash(api_response)
      tag.displayable_self
    end

    ##
    # Finds a Tag using a name
    def self.find_by_name(name)
      find({:name => name})
    end

    ##
    # Creates a new Tag using params and saves it
    # @see #save
    def self.create(params)
      requires_parameters(params, %W(name))
      Tag.new(params).save
    end

    ##
    # Saves a Tag on your application
    def save
      response = Intercom.post("/v1/tags", to_wire)
      self.from_hash(response)
      displayable_self
    end

    ##
    # Create a new clean instance to return (only showing the readable attributes)
    def displayable_self
      Tag.new(self.displayable_attributes)
    end
  end
end