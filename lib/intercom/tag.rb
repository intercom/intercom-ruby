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

  class Tag < IntercomBaseObject

    ENDPOINT = "/v1/tags"
    REQUIRED_PARAMS = %W(name)

    attr_accessor :name, :color
    attr_reader :segment, :tagged_user_count, :id
    attr_writer :user_ids, :emails, :tag_or_untag

    ##
    # Finds a Tag using params
    def self.find(params)
      response = Intercom.get("/v1/tags", params)
      from_api(response)
    end

    ##
    # Finds a Tag using a name
    def self.find_by_name(name)
      find({:name => name})
    end

  end
end