# intercom-ruby

Ruby bindings for the Intercom API (https://api.intercom.io).

[API Documentation](https://api.intercom.io/docs)

[Gem Documentation](http://rubydoc.info/github/intercom/intercom-ruby/master/frames)

For generating Intercom javascript script tags for Rails, please see https://github.com/intercom/intercom-rails

## Installation

    gem install intercom

Using bundler:

    gem 'intercom'

## Basic Usage

### Configure your access credentials

```ruby
Intercom.app_id = "my_app_id"
Intercom.api_key = "my-super-crazy-api-key"
```

### Resources

The API supports:

    POST,PUT,GET https://api.intercom.io/v1/users
    POST,PUT,GET https://api.intercom.io/v1/users/messages
    POST https://api.intercom.io/v1/users/impressions
    POST https://api.intercom.io/v1/users/notes

### Examples

#### Users

```ruby
user = Intercom::User.find_by_email("bob@example.com")
user.custom_data["average_monthly_spend"] = 1234.56
user.save
user = Intercom::User.find_by_user_id("1")
user = Intercom::User.create(:email => "bob@example.com", :name => "Bob Smith")
user = Intercom::User.new(params)
user.save
Intercom::User.all.count
Intercom::User.all.each {|user| puts %Q(#{user.email} - #{user.custom_data["average_monthly_spend"]}) }
Intercom::User.all.map {|user| user.email }
```

#### Companies
```ruby
user = Intercom::User.find_by_email("bob@example.com")
user.company = {:id => 6, :name => "Intercom"}
user.companies = [{:id => 6, :name => "Intercom"}, {:id => 9, :name => "Test Company"}]
```

You can also pass custom data within a company:

```ruby
user.company = {:id => 6, :name => "Intercom", :referral_source => "Google"}
```

#### Message Threads
```ruby
Intercom::MessageThread.create(:email => "bob@example.com", :body => "Example message from bob@example.com to your application on Intercom.")
Intercom::MessageThread.find(:email => "bob@example.com", :thread_id => 123)
Intercom::MessageThread.find_all(:email => "bob@example.com")
Intercom::MessageThread.mark_as_read(:email => "bob@example.com", :thread_id => 123)
```

#### Impressions
```ruby
Intercom::Impression.create(:email => "bob@example.com", :location => "/path/in/my/app", :user_ip => "1.2.3.4", :user_agent => "my-savage-iphone-app-0.1"
```

#### Notes
```ruby
Intercom::Note.create(:email => "bob@example.com", :body => "This is the text of the note")
```

#### Events
The simplest way to create an event is directly on the user
```ruby
user = Intercom::User.find_by_email("bob@example.com")
user.track_event("invited-friend")
```

For more control create events through Intercom::Event
```ruby
Intercom::Event.create(:event_name => "invited-friend", :user => user)

# With an explicit event creation date
Intercom::Event.create(:event_name => "invited-friend", :user => user, :created_at => 1391691571)

# With metadata
Intercom::Event.create(:event_name => "invited-friend", :user => user,
  metadata => { 
    :invitee_email => 'pi@example.org',  
    :invite_code => 'ADDAFRIEND'
  }
)
```

Metadata Objects support a few simple types that Intercom can present on your behalf 

```ruby
Intercom::Event.create(:event_name => "placed-order", :user => current_user,
  metadata => { 
    :order_date => Time.now.to_i,  
    :stripe_invoice => 'inv_3434343434', 
    :order_number => { 
      :value => '3434-3434', 
      :url => 'https://example.org/orders/3434-3434' 
    },
    price: { 
      :currency => 'usd',  
      :amount => 2999 
    }    
  }
)
```

The metadata key values in the example are treated as follows-
- order_date: a Date (key ends with '_date').
- stripe_invoice: The identifier of the Stripe invoice (has a 'stripe_invoice' key)
- order_number: a Rich Link (value contains 'url' and 'value' keys)
- price: An Amount in US Dollars (value contains 'amount' and 'currency' keys)

### Errors
```ruby
Intercom::AuthenticationError
Intercom::ServerError
Intercom::ServiceUnavailableError
Intercom::ResourceNotFound
```
