require 'intercom/user_resource'
require 'intercom/flat_store'
require 'intercom/social_profile'

module Intercom
  # A collection of your Users from Intercom
  # Uses the paginated users api under the covers (http://docs.intercom.io/api#getting_all_users)
  #
  # == Examples:
  #
  # Iterating over each user
  #    Intercom::User.all.each do |user|
  #      puts user.inspect
  #    end
  #
  class UserCollectionProxy

    def initialize(emails = nil)
      @emails = emails
    end

    def emails_each(&block)
      @emails.each do |email|
        block.call User.find_by_email(email)
      end
    end

    # yields each {User} to the block provided
    # @return [void]
    def all_each(&block)
      page = 1
      fetch_another_page = true
      while fetch_another_page
        current_page = Intercom.get("/v1/users", {:page => page})
        current_page["users"].each do |user|
          block.call User.from_api(user)
        end
        page = page + 1
        fetch_another_page = !current_page["next_page"].nil?
      end
    end

    def each(&block)
      @emails ? emails_each(&block) : all_each(&block)
    end

    include Enumerable

    # This method exists as an optimisation of Enumerable#count,
    # which would potentially fetch multiple pages of users.
    def count(item=nil) #:nodoc:
      return super unless item.nil?
      return super if block_given?

      @emails ? @emails.count : Intercom::User.count
    end
  end
end
