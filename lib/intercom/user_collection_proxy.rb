require 'intercom/user_resource'
require 'intercom/user_custom_data'
require 'intercom/social_profile'

module Intercom
  # A collection of your Users from Intercom
  # Uses the paginated users api under the covers (http://docs.intercom.io/api#getting_all_users)
  #
  # == Examples:
  #
  # Fetching a count of all Users tracked on Intercom
  #    Intercom::User.all.count
  #
  # Iterating over each user
  #    Intercom::User.all.each do |user|
  #      puts user.inspect
  #    end
  #
  class UserCollectionProxy
    include Enumerable

    # @return [Integer] number of users tracked on Intercom for this application
    def count
      raise ArgumentError.new("count doesn't support block argument") if block_given?
      response = Intercom.get("users", {:per_page => 1})
      response["total_count"]
    end

    # yields each {User} to the block provided
    # @return [void]
    def each(&block)
      page = 1
      fetch_another_page = true
      while fetch_another_page
        current_page = Intercom.get("users", {:page => page})
        current_page["users"].each do |user|
          block.call User.from_api(user)
        end
        page = page + 1
        fetch_another_page = !current_page["next_page"].nil?
      end
    end
  end
end
