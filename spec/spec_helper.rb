require 'intercom'
require 'minitest/autorun'
require 'mocha'
require 'pry'
IRB = Pry

def test_user
  {
      :user_id => 'mysql-id-from-customers-app for eg', # can request by this
      :email => "bo@example.com", # can request by this
      :name => "Joe Schmoe",
      :created_at => 1323422442,
      :session_count => 123,
      :last_impression_at => 1323422442,
      :custom_data => {"one" => 1, "a" => {"nested-hash" => ["ab", 12, {"deep" => "very-deep"}]}},
      :social_accounts => [
          {"type" => "twitter", "url" => "http://twitter.com/abc", "username" => "abc"},
          {"type" => "twitter", "username" => "abc2", "url" => "http://twitter.com/abc2"},
          {"type" => "facebook", "url" => "http://facebook.com/abc", "username" => "abc", "id" => "1234242"},
          {"type" => "quora", "url" => "http://facebook.com/abc", "username" => "abc", "id" => "1234242"}
      ],
      :location_data => {
          "some" => "thing"
      }
  }
end

def test_messages
  [
      test_message, test_message
  ]
end

def test_message
  {
      "created_at" => 1329837506,
      "updated_at" => 1329664706,
      "read" => true,
      "created_by_user" => true,
      "thread_id" => 5591,
      "conversation" => [
          {
              "created_at" => 1329837506,
              "rendered_body" => "<p>Hey Intercom, What is up?</p>\n",
              "from" => {
                  "email" => "bob@example.com",
                  "name" => "Bob",
                  "user_id" => "123"
              },
              "is_admin" => false
          },
          {
              "created_at" => 1329664706,
              "rendered_body" => "<p>Not much, you?</p>\n",
              "from" => {
                  "name" => "Super Duper Admin",
                  "avatar_path_50" => "https//s3.amazonaws.com/intercom-prod/app/public/system/avatars/1454/medium/intercom-ben-avatar.jpg?1326725052"
              },
              "is_admin" => true
          },
          {
              "created_at" => 1329664706,
              "rendered_body" => "<p>Not much either :(</p>\n",
              "from" => {
                  "email" => "bob@example.com",
                  "name" => "Bob",
                  "user_id" => "123"
              },
              "is_admin" => false
          }
      ]
  }
end