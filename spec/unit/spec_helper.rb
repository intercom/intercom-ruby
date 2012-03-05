require 'intercom'
require 'minitest/autorun'
require 'mocha'

def test_user
  {
      :user_id => 'id-from-customers-app',
      :email => "bo@example.com",
      :name => "Joe Schmoe",
      :created_at => 1323422442,
      :last_seen_ip  => "1.2.3.4",
      :last_seen_user_agent  => "Mozilla blah blah ie6",
      :custom_data => {"a" => "b", "b" => 2},
      :relationship_score  => 90,
      :session_count => 123,
      :last_impression_at => 1323422442,
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

def capture_exception(&block)
  begin
    block.call
  rescue => e
    return e
  end
end