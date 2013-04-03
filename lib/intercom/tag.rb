require 'intercom/user_resource'

module Intercom

  ##
  # Represents a tag
  #
  # A tag consists of a name, and (optionally) a color and users that you would like to tag.
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
  #  tag.user_ids << 'abc123'
  #  tag.tag_or_untag = "untag"
  #  tag.save

  class Tag < UserResource

    def initialize(attributes={})
      @attributes = attributes
    end

    ##
    # Finds a Tag using params
    def self.find(params)
      response = Intercom.get("/v1/tags", params)
      Tag.from_api(response)
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
      response = Intercom.post("/v1/tags", to_hash)
      self.update_from_api_response(response)
    end

    ##
    # The name of the tag
    def name=(name)
      @attributes["name"] = name
    end

    ##
    # The color of the tag
    def color=(color)
      @attributes["color"] = color
    end

    ##
    # An array of user_ids of the users you'd like to tag or untag
    def user_ids
      @attributes["user_ids"] ||= []
    end

    ##
    # An array of user_ids of the users you'd like to tag or untag
    def emails
      @attributes["emails"] ||= []
    end

    ##
    # An array of user_ids of the users you'd like to tag or untag
    def user_ids=(user_ids)
      @attributes["user_ids"] = user_ids
    end

    ##
    # An array of emails of the users you'd like to tag or untag
    def emails=(emails)
      @attributes["emails"] = emails
    end

    ##
    # A string to specify whether to tag or untag the specified users, can be left out if only creating a new tag.
    def tag_or_untag=(tag_or_untag)
      return unless ["tag", "untag"].include?(tag_or_untag)
      @attributes["tag_or_untag"] = tag_or_untag
    end

  end
end