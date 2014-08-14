# intercom-ruby

Ruby bindings for the Intercom API (https://api.intercom.io).

[API Documentation](https://api.intercom.io/docs)

[Gem Documentation](http://rubydoc.info/github/intercom/intercom-ruby/master/frames)

For generating Intercom javascript script tags for Rails, please see https://github.com/intercom/intercom-rails

## Upgrading information
Version 2 of intercom-ruby is not backwards compatible with previous versions. Be sure to test this new version before deploying to production. One other change you will need to make as part of the upgrade is to set `Intercom.app_api_key` and not set `Intercom.api_key` (you can continue to use your existing API key).

This version of the gem is compatible with `Ruby 2.1`, `Ruby 2.0` & `Ruby 1.9.3`

## Installation

    gem install intercom

Using bundler:

    gem 'intercom', "~> 2.1.3"

## Basic Usage

### Configure your access credentials

```ruby
Intercom.app_id = "my_app_id"
Intercom.app_api_key = "my-super-crazy-api-key"
```

### Resources

Resources this API supports:

    https://api.intercom.io/users
    https://api.intercom.io/companies
    https://api.intercom.io/tags
    https://api.intercom.io/notes
    https://api.intercom.io/segments
    https://api.intercom.io/events
    https://api.intercom.io/conversations
    https://api.intercom.io/messages
    https://api.intercom.io/counts

### Examples

#### Users

```ruby
# Find user by email
user = Intercom::User.find(:email => "bob@example.com")
# Find user by user_id
user = Intercom::User.find(:user_id => "1")
# Find user by id
user = Intercom::User.find(:id => "1")
# Create a user
user = Intercom::User.create(:email => "bob@example.com", :name => "Bob Smith")
# Update custom_attributes for a user
user.custom_attributes["average_monthly_spend"] = 1234.56; user.save
# Perform incrementing
user.increment('karma'); user.save
# Iterate over all users
Intercom::User.all.each {|user| puts %Q(#{user.email} - #{user.custom_attributes["average_monthly_spend"]}) }
Intercom::User.all.map {|user| user.email }
```

#### Admins
```ruby
# Iterate over all admins
Intercom::Admin.all.each {|admin| puts admin.email }
```

#### Companies
```ruby
# Add a user to one or more companies
user = Intercom::User.find(:email => "bob@example.com")
user.companies = [{:company_id => 6, :name => "Intercom"}, {:company_id => 9, :name => "Test Company"}]; user.save
# You can also pass custom attributes within a company as you do this
user.companies = [{:id => 6, :name => "Intercom", :custom_attributes => {:referral_source => "Google"} } ]; user.save
# Find a company by company_id
company = Intercom::Company.find(:company_id => "44")
# Find a company by name
company = Intercom::Company.find(:name => "Some company")
# Find a company by id
company = Intercom::Company.find(:id => "41e66f0313708347cb0000d0")
# Update a company
company.name = 'Updated company name'; company.save
# Iterate over all companies
Intercom::Company.all.each {|company| puts %Q(#{company.name} - #{company.custom_attributes["referral_source"]}) }
Intercom::Company.all.map {|company| company.name }
# Get a list of users in a company
company.users
```

#### Tags
```ruby
# Tag users
tag = Intercom::Tag.tag_users('blue', ["42ea2f1b93891f6a99000427"])
# Untag users
Intercom::Tag.untag_users('blue', ["42ea2f1b93891f6a99000427"])
# Iterate over all tags
Intercom::Tag.all.each {|tag| "#{tag.id} - #{tag.name}" }
Intercom::Tag.all.map {|tag| tag.name }
# Iterate over all tags for user
Intercom::Tag.find_all_for_user(:id => '53357ddc3c776629e0000029')
Intercom::Tag.find_all_for_user(:email => 'declan+declan@intercom.io')
Intercom::Tag.find_all_for_user(:user_id => '3')
# Tag companies
tag = Intercom::Tag.tag_companies('red', ["42ea2f1b93891f6a99000427"])
# Untag companies
Intercom::Tag.untag_users('blue', ["42ea2f1b93891f6a99000427"])
# Iterate over all tags for company
Intercom::Tag.find_all_for_company(:id => '43357e2c3c77661e25000026')
Intercom::Tag.find_all_for_company(:company_id => '6')
```

#### Segments
```ruby
# Find a segment
segment = Intercom::Segment.find(:id => segment_id)
# Update a segment
segment.name = 'Updated name'; segment.save
# Iterate over all segments
Intercom::Segment.all.each {|segment| puts "id: #{segment.id} name: #{segment.name}"}
```

#### Notes
```ruby
# Find a note by id
note = Intercom::Note.find(:id => note)
# Create a note for a user
note = Intercom::Note.create(:body => "<p>Text for the note</p>", :email => 'joe@example.com')
# Iterate over all notes for a user via their email address
Intercom::Note.find_all(:email => 'joe@example.com').each {|note| puts note.body}
# Iterate over all notes for a user via their user_id
Intercom::Note.find_all(:user_id => '123').each {|note| puts note.body}
```

#### Conversations
```ruby
# FINDING CONVERSATIONS FOR AN ADMIN
# Iterate over all conversations (open and closed) assigned to an admin
Intercom::Conversation.find_all(:type => 'admin', :id => '7').each do {|convo| ... }
# Iterate over all open conversations assigned to an admin
Intercom::Conversation.find_all(:type => 'admin', :id => 7, :open => true).each do {|convo| ... }
# Iterate over closed conversations assigned to an admin
Intercom::Conversation.find_all(:type => 'admin', :id => 7, :open => false).each do {|convo| ... }
# Iterate over closed conversations for assigned an admin, before a certain moment in time
Intercom::Conversation.find_all(:type => 'admin', :id => 7, :open => false, :before => 1374844930).each do {|convo| ... }

# FINDING CONVERSATIONS FOR A USER
# Iterate over all conversations (read + unread, correct) with a user based on the users email
Intercom::Conversation.find_all(:email => 'joe@example.com', :type => 'user').each do {|convo| ... }
# Iterate over through all conversations (read + unread) with a user based on the users email
Intercom::Conversation.find_all(:email => 'joe@example.com', :type => 'user', :unread => false).each do {|convo| ... }
# Iterate over all unread conversations with a user based on the users email
Intercom::Conversation.find_all(:email => 'joe@example.com', :type => 'user', :unread => true).each do {|convo| ... }

# FINDING A SINGLE CONVERSATION
conversation = Intercom::Conversation.find(:id => '1')

# INTERACTING WITH THE PARTS OF A CONVERSATION
# Getting the subject of a part (only applies to email-based conversations)
conversation.rendered_message.subject
# Get the part_type of the first part
conversation.conversation_parts[0].part_type
# Get the body of the second part
conversation.conversation_parts[1].body

# REPLYING TO CONVERSATIONS
# User (identified by email) replies with a comment
conversation.reply(:type => 'user', :email => 'joe@example.com', :message_type => 'comment', :body => 'foo')
# Admin (identified by email) replies with a comment
conversation.reply(:type => 'admin', :email => 'bob@example.com', :message_type => 'comment', :body => 'bar')

# MARKING A CONVERSATION AS READ
conversation.read = true
conversation.save
```

#### Counts
```ruby
# Get Conversation per Admin
conversation_counts_for_each_admin = Intercom::Count.conversation_counts_for_each_admin
conversation_counts_for_each_admin.each{|count| puts "Admin: #{count.name} (id: #{count.id}) Open: #{count.open} Closed: #{count.closed}" }
# Get User Tag Count Object
Intercom::Count.user_counts_for_each_tag
# Get User Segment Count Object
Intercom::Count.user_counts_for_each_segment
# Get Company Segment Count Object
Intercom::Count.company_counts_for_each_segment
# Get Company Tag Count Object
Intercom::Count.company_counts_for_each_tag
# Get Company User Count Object
Intercom::Count.company_counts_for_each_user
# Get total count of companies, users, segments or tags across app
Intercom::Company.count
Intercom::User.count
Intercom::Segment.count
Intercom::Tag.count
```

#### Full loading of and embedded entity
```ruby
# Given a converation with a partial user, load the full user. This can be done for any entity
conversation.user.load
```

#### Sending messages
```ruby

# InApp message from admin to user
Intercom::Message.create({
  :message_type => 'inapp',
  :body => "What's up :)",
  :from => {
    :type => 'admin',
    :id   => "1234"
  },
  :to => {
    :type => :user,
    :id   => "5678"
  }
})

# Email message from admin to user
Intercom::Message.create({
  :message_type => 'email',
  :subject  => 'Hey there',
  :body     => "What's up :)",
  :template => "plain", # or "personal",
  :from => {
    :type => "admin",
    :id   => "1234"
  },
  :to => {
    :type => "user",
    :id => "536e564f316c83104c000020"
  }
})

# Message from a user
Intercom::Message.create({
  :from => {
    :type => "user",
    :id => "536e564f316c83104c000020"
  },
  :body => "halp"
})
```

#### Events
```ruby
Intercom::Event.create(
  :event_name => "invited-friend", :created_at => Time.now.to_i,
  :email => user.email,
  :metadata => {
    "invitee_email" => "pi@example.org",
    :invite_code => "ADDAFRIEND",
    "found_date" => 12909364407
  }
)
```

Metadata Objects support a few simple types that Intercom can present on your behalf

```ruby
Intercom::Event.create(:event_name => "placed-order", :email => current_user.email,
  :created_at => 1403001013
  :metadata => {
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
You do not need to deal with the HTTP response from an API call directly. If there is an unsuccessful response then an error that is a subclass of Intercom:Error will be raised. If desired, you can get at the http_code of an Intercom::Error via it's `http_code` method.

The list of different error subclasses are listed below. As they all inherit off Intercom::Error you can choose to rescue Intercom::Error or
else rescue the more specific error subclass.

```ruby
Intercom::AuthenticationError
Intercom::ServerError
Intercom::ServiceUnavailableError
Intercom::ResourceNotFound
Intercom::BadRequestError
Intercom::RateLimitExceeded
Intercom::AttributeNotSetError # Raised when you try to call a getter that does not exist on an object
```
