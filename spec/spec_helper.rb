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

def test_user_dates(email="bob@example.com", created_at=1401970114, last_request_at=1401970113)
  {
      "type" =>"user",
      "id" =>"aaaaaaaaaaaaaaaaaaaaaaaa",
      "user_id" => 'id-from-customers-app',
      "email" => email,
      "name" => "Joe Schmoe",
      "avatar" => {"type"=>"avatar", "image_url"=>"https://graph.facebook.com/1/picture?width=24&height=24"},
      "app_id" => "the-app-id",
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
      "last_request_at" =>last_request_at,
      "created_at" =>created_at,
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

def test_admin_list
  {
    "type" => "admin.list",
    "admins" => [
      {
        "type" => "admin",
        "id" => "1234",
        "name" => "Hoban Washburne",
        "email" => "wash@serenity.io"
      }
    ]
  }
end

def test_admin
  {
    "type" => "admin",
    "id" => "1234",
    "name" => "Hoban Washburne",
    "email" => "wash@serenity.io"
  }
end

def test_company
  {
    "type" => "company",
    "id" => "531ee472cce572a6ec000006",
    "name" => "Blue Sun",
    "plan" => {
      "type" =>"plan",
      "id" =>"1",
      "name" =>"Paid"
    },
    "company_id" => "6",
    "remote_created_at" => 1394531169,
    "created_at" => 1394533506,
    "updated_at" => 1396874658,
    "last_request_at" => 1396874658,
    "monthly_spend" => 49,
    "session_count" => 26,
    "user_count" => 10,
    "custom_attributes" => {
      "paid_subscriber"  => true,
      "team_mates" => 0
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

def page_of_users(include_next_link= false)
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

def users_scroll(include_users= false)
  {
      "type"=>"user.list",
      "scroll_param"=> ("da6bbbac-25f6-4f07-866b-b911082d7"),
      "users"=> (include_users ? [test_user("user1@example.com"), test_user("user2@example.com"), test_user("user3@example.com")] : []),
  }
end

def users_pagination(include_next_link=false, per_page=0, page=0, total_pages=0, total_count=0, user_list=[])
  {
      "type"=>"user.list",
      "pages"=>
          {
              "type"=>"pages",
              "next"=> (include_next_link ? "https://api.intercom.io/users?per_page=" \
                                            + per_page.to_s + "&page=" +  (page+1).to_s : nil),
              "page"=>page,
              "per_page"=>per_page,
              "total_pages"=>total_pages
          },
      "users"=> user_list,
      "total_count"=>total_count
  }
end

def test_conversation
  {
    "type" => "conversation",
    "id" => "147",
    "created_at" => 1400850973,
    "updated_at" => 1400857494,
    "conversation_message" => {
      "type" => "conversation_message",
      "subject" => "",
      "body" => "<p>Hi Alice,</p>\n\n<p>We noticed you using our Product, do you have any questions?</p> \n<p>- Jane</p>",
      "author" => {
        "type" => "admin",
        "id" => "25"
      },
      "attachments" => [
        {
          "name" => "signature",
          "url" => "http =>//someurl.com/signature.jpg"
        }
      ]
    },
    "user" => {
      "type" => "user",
      "id" => "536e564f316c83104c000020"
    },
    "assignee" => {
      "type" => "admin",
      "id" => "25"
    },
    "open" => true,
    "read" => true,
    "conversation_parts" => {
      "type" => "conversation_part.list",
      "conversation_parts" => [
      ]
    }
  }
end

def segment
  {
    "type" => "segment",
    "id" => "5310d8e7598c9a0b24000002",
    "name" => "Active",
    "created_at" => 1393613031,
    "updated_at" => 1393613031
  }
end

def segment_list
  {
    "type" => "segment.list",
    "segments" => [
      {
        "created_at" => 1393613031,
        "id" => "5310d8e7598c9a0b24000002",
        "name" => "Active",
        "type" => "segment",
        "updated_at" => 1393613031
      },
      {
        "created_at" => 1393613030,
        "id" => "5310d8e6598c9a0b24000001",
        "name" => "New",
        "type" => "segment",
        "updated_at" => 1393613030
      },
      {
        "created_at" => 1393613031,
        "id" => "5310d8e7598c9a0b24000003",
        "name" => "Slipping Away",
        "type" => "segment",
        "updated_at" => 1393613031
      }
    ]
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

def test_user_notification
  {
    "type" => "notification_event",
    "id" => "notif_123456-56465-546546",
    "topic" => "user.created",
    "app_id" => "aaaaaa",
    "data" =>
    {
      "type" => "notification_event_data",
      "item" =>
      {
        "type" => "user",
        "id" => "aaaaaaaaaaaaaaaaaaaaaaaa",
        "user_id" => nil,
        "email" => "joe@example.com",
        "name" => "Joe Schmoe",
        "avatar" =>
        {
          "type" => "avatar",
          "image_url" => nil
        },
        "app_id" => "aaaaa",
        "companies" =>
        {
          "type" => "company.list",
          "companies" => [ ]
        },
        "location_data" =>
        {
        },
        "last_request_at" => nil,
        "created_at" => "1401970114",
        "remote_created_at" => nil,
        "updated_at" => "1401970114",
        "session_count" => 0,
        "social_profiles" =>
        {
          "type" => "social_profile.list",
          "social_profiles" => [ ]
        },
        "unsubscribed_from_emails" => false,
        "user_agent_data" => nil,
        "tags" =>
        {
          "type" => "tag.list",
          "tags" => [ ]
        },
        "segments" =>
        {
          "type" => "segment.list",
          "segments" => [ ]
        },
        "custom_attributes" =>
        {
        }
      }
    },
    "delivery_status" => nil,
    "delivery_attempts" => 1,
    "delivered_at" => 0,
    "first_sent_at" => 1410188629,
    "created_at" => 1410188628,
    "links" => { },
    "self" => nil
  }
end

def test_conversation_notification
  {
     "type"=>"notification_event",
     "id"=>"notif_123456-56465-546546",
     "topic"=>"conversation.user.created",
     "app_id"=>"aaaaa",
     "data"=>
     {
          "type"=>"notification_event_data",
          "item"=>
          {
               "type"=>"conversation",
               "id"=>"123456789",
               "created_at"=>"1410335293",
               "updated_at"=>"1410335293",
               "user"=>
               {
                    "type"=>"user",
                    "id"=>"540f1de7112d3d1d51001637",
                    "name"=>"Kill Bill",
                    "email"=>"bill@bill.bill"},
               "assignee"=>
               {
                   "type"=>"nobody_admin",
                   "id"=>nil
               },
               "conversation_message"=>
               {
                    "type"=>"conversation_message",
                    "id"=>"321546",
                    "subject"=>"",
                    "body"=>"<p>An important message</p>",
                    "author"=>
                    {
                         "type"=>"user",
                         "id"=>"aaaaaaaaaaaaaaaaaaaaaa",
                         "name"=>"Kill Bill",
                         "email"=>"bill@bill.bill"},
                    "attachments"=>[]
               },
               "conversation_parts"=>
               {
                   "type"=>"conversation_part.list",
                   "conversation_parts"=>[]
               },
               "open"=>nil,
               "read"=>true,
               "links"=>
               {
                   "conversation_web"=>
                    "https://app.intercom.io/a/apps/aaaaaa/inbox/all/conversations/123456789"}
          }
     },
     "delivery_status"=>nil,
     "delivery_attempts"=>1,
     "delivered_at"=>0,
     "first_sent_at"=>1410335293,
     "created_at"=>1410335293,
     "links"=>{},
     "self"=>nil
  }
end

def test_subscription
  {"request"=>
       {"type"=>"notification_subscription",
        "id"=>"nsub_123456789",
        "created_at"=>1410368642,
        "updated_at"=>1410368642,
        "service_type"=>"web",
        "app_id"=>"3qmk5gyg",
        "url"=>
            "http://example.com",
        "self"=>
            "https://api.intercom.io/subscriptions/nsub_123456789",
        "topics"=>["user.created", "conversation.user.replied", "conversation.admin.replied"],
        "active"=>true,
        "metadata"=>{},
        "hub_secret"=>nil,
        "mode"=>"point",
        "links"=>
            {"sent"=>
                 "https://api.intercom.io/subscriptions/nsub_123456789/sent",
             "retry"=>
                 "https://api.intercom.io/subscriptions/nsub_123456789/retry",
             "errors"=>
                 "https://api.intercom.io/subscriptions/nsub_123456789/errors"},
        "notes"=>[]}}
end

def test_app_count
  {
    "type" => "count.hash",
    "company" => {
      "count" => 8
    },
    "segment" => {
      "count" => 47
    },
    "tag" => {
      "count" => 341
    },
    "user" => {
      "count" => 12239
    }
  }
end

def test_segment_count
  {
    "type" => "count",
    "user" => {
      "segment" => [
        {
          "Active" => 1
        },
        {
          "New" => 0
        },
        {
          "VIP" => 0
        },
        {
          "Slipping Away" => 0
        },
        {
          "segment 1" => 1
        }
      ]
    }
  }
end

def test_conversation_count
  {
    "type" => "count",
    "conversation" => {
      "assigned" => 1,
      "closed" => 15,
      "open" => 1,
      "unassigned" => 0
    }
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
