require 'intercom'
require 'minitest/autorun'
require 'mocha/setup'

def test_user(email="bob@example.com")
  {
    "type" =>"user",
    "id" =>"aaaaaaaaaaaaaaaaaaaaaaaa",
    "user_id" => 'id-from-customers-app',
    "email" => email,
    "name" => "Joe Schmoe",
    "avatar" => {"type"=>"avatar", "image_url"=>"https://graph.facebook.com/1/picture?width=24&height=24"},
    "app_id" => "the-app-id",
    "created_at" => 1323422442,
    "custom_attributes" => {"a" => "b", "b" => 2},
    "companies" =>
     {"type"=>"company.list",
      "companies"=>
       [{"type"=>"company",
         "company_id"=>"123",
         "id"=>"bbbbbbbbbbbbbbbbbbbbbbbb",
         "app_id"=>"the-app-id",
         "name"=>"Company 1",
         "remote_created_at"=>1390936440,
         "created_at"=>1401970114,
         "updated_at"=>1401970114,
         "last_request_at"=>1401970113,
         "monthly_spend"=>0,
         "session_count"=>0,
         "user_count"=>1,
         "tag_ids"=>[],
         "custom_attributes"=>{"category"=>"Tech"}}]},
    "session_count" => 123,
    "unsubscribed_from_emails" => true,
    "last_request_at" =>1401970113,
    "created_at" =>1401970114,
    "remote_created_at" =>1393613864,
    "updated_at" =>1401970114,
    "user_agent_data" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11",
    "social_profiles" =>{"type"=>"social_profile.list",
       "social_profiles" => [
           {"type" => "social_profile", "name" => "twitter", "url" => "http://twitter.com/abc", "username" => "abc", "id" => nil},
           {"type" => "social_profile", "name" => "twitter", "username" => "abc2", "url" => "http://twitter.com/abc2", "id" => nil},
           {"type" => "social_profile", "name" => "facebook", "url" => "http://facebook.com/abc", "username" => "abc", "id" => "1234242"},
           {"type" => "social_profile", "name" => "quora", "url" => "http://facebook.com/abc", "username" => "abc", "id" => "1234242"}
       ]},
   "location_data"=>
    {"type"=>"location_data",
     "city_name"=> 'Dublin',
     "continent_code"=> 'EU',
     "country_name"=> 'Ireland',
     "latitude"=> '90',
     "longitude"=> '10',
     "postal_code"=> 'IE',
     "region_name"=> 'Europe',
     "timezone"=> '+1000',
     "country_code" => "IRL"}
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
                  "avatar" => {
                    "square_25" => "https://static.intercomcdn.com/avatars/13347/square_25/Ruairi_Profile.png?1375368166",
                    "square_50" => "https://static.intercomcdn.com/avatars/13347/square_50/Ruairi_Profile.png?1375368166",
                    "square_128" => "https://static.intercomcdn.com/avatars/13347/square_128/Ruairi_Profile.png?1375368166"
                  },
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

def page_of_users(include_next_link: false)
  {
     "type"=>"user.list",
     "pages"=>
      {
        "type"=>"pages",
        "next"=> (include_next_link ? "https://api.intercom.io/users?per_page=50&page=2" : nil),
        "page"=>1,
        "per_page"=>50,
        "total_pages"=>7
      },
      "users"=> [test_user("user1@example.com"), test_user("user2@example.com"), test_user("user3@example.com")],
      "total_count"=>314
  }
end

def test_tag
  {
    "id" => "4f73428b5e4dfc000b000112",
    "name" => "Test Tag",
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
