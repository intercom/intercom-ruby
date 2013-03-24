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
  #  tag.save

  class Tag < UserResource

    def initialize(params)
      @attributes = params
    end

    ##
    # Creates a new Tag using params and saves it
    # @see #save
    def self.create(params)
      requires_parameters(params, %W(name))
      Tag.new(params).save
    end

    ##
    # Saves a note on your application
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
    def user_ids=(user_ids)
      @attributes["user_ids"] = user_ids
    end

    ##
    # An array of emails of the users you'd like to tag or untag
    def emails=(emails)
      @attributes["emails"] = emails
    end

  end
end