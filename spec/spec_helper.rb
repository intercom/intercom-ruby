require 'intercom'
require 'minitest/autorun'
require 'mocha/setup'

def test_user(email="bob@example.com")
  {
      :user_id => 'id-from-customers-app',
      :email => email,
      :name => "Joe Schmoe",
      :created_at => 1323422442,
      :last_seen_ip => "1.2.3.4",
      :last_seen_user_agent => "Mozilla blah blah ie6",
      :custom_data => {"a" => "b", "b" => 2},
      :relationship_score => 90,
      :session_count => 123,
      :last_impression_at => 1323422442,
      :unsubscribed_from_emails => true,
      :social_profiles => [
          {"type" => "twitter", "url" => "http://twitter.com/abc", "username" => "abc"},
          {"type" => "twitter", "username" => "abc2", "url" => "http://twitter.com/abc2"},
          {"type" => "facebook", "url" => "http://facebook.com/abc", "username" => "abc", "id" => "1234242"},
          {"type" => "quora", "url" => "http://facebook.com/abc", "username" => "abc", "id" => "1234242"}
      ],
      :location_data => {
          "country_code" => "IRL"
      }
  }
end

def test_messages
  [test_message, test_message]
end

def test_message
  {
      "created_at" => 1329837506,
      "updated_at" => 1329664706,
      "read" => true,
      "created_by_user" => true,
      "thread_id" => 5591,
      "messages" => [
          {
              "created_at" => 1329837506,
              "html" => "<p>Hey Intercom, What is up?</p>\n",
              "from" => {
                  "email" => "bob@example.com",
                  "name" => "Bob",
                  "user_id" => "123",
                  "is_admin" => false
              }
          },
          {
              "created_at" => 1329664706,
              "rendered_body" => "<p>Not much, you?</p>\n",
              "from" => {
                  "name" => "Super Duper Admin",
                  "avatar_path_50" => "https//s3.amazonaws.com/intercom-prod/app/public/system/avatars/1454/medium/intercom-ben-avatar.jpg?1326725052",
                  "is_admin" => true
              }
          },
          {
              "created_at" => 1329664806,
              "rendered_body" => "<p>Not much either :(</p>\n",
              "from" => {
                  "email" => "bob@example.com",
                  "name" => "Bob",
                  "user_id" => "123",
                  "is_admin" => false
              }
          }
      ]
  }
end

def page_of_users(page=1, per_page=10)
  all_users = [test_user("user1@example.com"), test_user("user2@example.com"), test_user("user3@example.com")]
  offset = (page - 1) * per_page
  limit = page * per_page
  next_page = limit < all_users.size ? page + 1 : nil
  previous_page = offset > 0 ? page - 1 : nil
  {
      "users" => all_users[offset..limit-1],
      "total_count" => all_users.size,
      "page" => page,
      "next_page" => next_page,
      "previous_page" => previous_page,
      "total_pages" => (all_users.size.to_f / per_page).ceil.to_i
  }
end

def test_tag
  {
    "id" => "4f73428b5e4dfc000b000112",
    "name" => "Test Tag",
    "color" => "red",
    "segment" => false,
    "tagged_user_count" => 2
  }
end

def error_on_modify_frozen
  RUBY_VERSION =~ /1.8/ ? TypeError : RuntimeError
end

def capture_exception(&block)
  begin
    block.call
  rescue => e
    return e
  end
end

def unshuffleable_array(array)
  def array.shuffle
    self
  end
  array
end
