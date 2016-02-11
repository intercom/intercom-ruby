# intercom-ruby

Ruby bindings for the Intercom API (https://api.intercom.io).

[API Documentation](https://api.intercom.io/docs)

[Gem Documentation](http://rubydoc.info/github/intercom/intercom-ruby/master/frames)

For generating Intercom javascript script tags for Rails, please see https://github.com/intercom/intercom-rails

## Upgrading information

Version 3 of intercom-ruby is not backwards compatible with previous versions.

Version 3 moves away from a global setup approach to the use of an Intercom Client.

This version of the gem is compatible with `Ruby 2.1` and above.

## Installation

    gem install intercom

Using bundler:

    gem 'intercom', "~> 3.3.0"

## Basic Usage

### Configure your client

```ruby
intercom = Intercom::Client.new(app_id: 'my_app_id', api_key: 'my_api_key')

# With an OAuth token:
intercom = Intercom::Client.new(token: 'my_token')
```

You can get your `app_id` from the URL when you're logged into Intercom (it's the alphanumeric just after `/apps/`) and your API key from the API keys integration settings page (under your app settings - integrations in Intercom).

### Resources

Resources this API supports:

    https://api.intercom.io/users
    https://api.intercom.io/contacts
    https://api.intercom.io/companies
    https://api.intercom.io/counts
    https://api.intercom.io/tags
    https://api.intercom.io/notes
    https://api.intercom.io/segments
    https://api.intercom.io/events
    https://api.intercom.io/conversations
    https://api.intercom.io/messages
    https://api.intercom.io/subscriptions
    https://api.intercom.io/jobs
    https://api.intercom.io/bulk

### Examples

#### Users

```ruby
# Find user by email
user = intercom.users.find(:email => "bob@example.com")
# Find user by user_id
user = intercom.users.find(:user_id => "1")
# Find user by id
user = intercom.users.find(:id => "1")
# Create a user
user = intercom.users.create(:email => "bob@example.com", :name => "Bob Smith", :signed_up_at => Time.now.to_i)
# Delete a user
user = intercom.users.find(:id => "1")
deleted_user = intercom.users.delete(user)
# Update custom_attributes for a user
user.custom_attributes["average_monthly_spend"] = 1234.56
intercom.users.save(user)
# Perform incrementing
user.increment('karma')
intercom.users.save(user)
# Iterate over all users
intercom.users.all.each {|user| puts %Q(#{user.email} - #{user.custom_attributes["average_monthly_spend"]}) }
intercom.users.all.map {|user| user.email }

#Bulk operations.
# Submit bulk job, to create users, if any of the items in create_items match an existing user that user will be updated
intercom.users.submit_bulk_job(create_items: [{user_id: 25, email: "alice@example.com"}, {user_id: 25, email: "bob@example.com"}])
# Submit bulk job, to delete users
intercom.users.submit_bulk_job(delete_items: [{user_id: 25, email: "alice@example.com"}, {user_id: 25, email: "bob@example.com"}])
# Submit bulk job, to add items to existing job
intercom.users.submit_bulk_job(create_items: [{user_id: 25, email: "alice@example.com"}], delete_items: [{user_id: 25, email: "bob@example.com"}], job_id:'job_abcd1234')
```

#### Admins
```ruby
# Iterate over all admins
intercom.admins.all.each {|admin| puts admin.email }
```

#### Companies
```ruby
# Add a user to one or more companies
user = intercom.users.find(:email => "bob@example.com")
user.companies = [{:company_id => 6, :name => "Intercom"}, {:company_id => 9, :name => "Test Company"}]
intercom.users.save(user)
# You can also pass custom attributes within a company as you do this
user.companies = [{:id => 6, :name => "Intercom", :custom_attributes => {:referral_source => "Google"} } ]
intercom.users.save(user)
# Find a company by company_id
company = intercom.companies.find(:company_id => "44")
# Find a company by name
company = intercom.companies.find(:name => "Some company")
# Find a company by id
company = intercom.companies.find(:id => "41e66f0313708347cb0000d0")
# Update a company
company.name = 'Updated company name'
intercom.companies.save(company)
# Iterate over all companies
intercom.companies.all.each {|company| puts %Q(#{company.name} - #{company.custom_attributes["referral_source"]}) }
intercom.companies.all.map {|company| company.name }
# Get a list of users in a company
intercom.companies.users(company.id)
```

#### Tags
```ruby
# Tag users
tag = intercom.tags.tag(name: 'blue', users: [{email: "test1@example.com"}])
# Untag users
intercom.tags.untag(name: 'blue',  users: [{user_id: "42ea2f1b93891f6a99000427"}])
# Iterate over all tags
intercom.tags.all.each {|tag| "#{tag.id} - #{tag.name}" }
intercom.tags.all.map {|tag| tag.name }
# Tag companies
tag = intercom.tags.tag(name: 'blue', companies: [{id: "42ea2f1b93891f6a99000427"}])
```

#### Segments
```ruby
# Find a segment
segment = intercom.segments.find(:id => segment_id)
# Iterate over all segments
intercom.segments.all.each {|segment| puts "id: #{segment.id} name: #{segment.name}"}
```

#### Notes
```ruby
# Find a note by id
note = intercom.notes.find(:id => note)
# Create a note for a user
note = intercom.notes.create(:body => "<p>Text for the note</p>", :email => 'joe@example.com')
# Iterate over all notes for a user via their email address
intercom.notes.find_all(:email => 'joe@example.com').each {|note| puts note.body}
# Iterate over all notes for a user via their user_id
intercom.notes.find_all(:user_id => '123').each {|note| puts note.body}
```

#### Conversations
```ruby
# FINDING CONVERSATIONS FOR AN ADMIN
# Iterate over all conversations (open and closed) assigned to an admin
intercom.conversations.find_all(:type => 'admin', :id => '7').each {|convo| ... }
# Iterate over all open conversations assigned to an admin
intercom.conversations.find_all(:type => 'admin', :id => 7, :open => true).each {|convo| ... }
# Iterate over closed conversations assigned to an admin
intercom.conversations.find_all(:type => 'admin', :id => 7, :open => false).each {|convo| ... }
# Iterate over closed conversations for assigned an admin, before a certain moment in time
intercom.conversations.find_all(:type => 'admin', :id => 7, :open => false, :before => 1374844930).each {|convo| ... }

# FINDING CONVERSATIONS FOR A USER
# Iterate over all conversations (read + unread, correct) with a user based on the users email
intercom.conversations.find_all(:email => 'joe@example.com', :type => 'user').each {|convo| ... }
# Iterate over through all conversations (read + unread) with a user based on the users email
intercom.conversations.find_all(:email => 'joe@example.com', :type => 'user', :unread => false).each {|convo| ... }
# Iterate over all unread conversations with a user based on the users email
intercom.conversations.find_all(:email => 'joe@example.com', :type => 'user', :unread => true).each {|convo| ... }

# FINDING A SINGLE CONVERSATION
conversation = intercom.conversations.find(:id => '1')

# INTERACTING WITH THE PARTS OF A CONVERSATION
# Getting the subject of a part (only applies to email-based conversations)
conversation.rendered_message.subject
# Get the part_type of the first part
conversation.conversation_parts[0].part_type
# Get the body of the second part
conversation.conversation_parts[1].body

# REPLYING TO CONVERSATIONS
# User (identified by email) replies with a comment
intercom.conversations.reply(:id => conversation.id, :type => 'user', :email => 'joe@example.com', :message_type => 'comment', :body => 'foo')
# Admin (identified by id) replies with a comment
intercom.conversations.reply(:id => conversation.id, :type => 'admin', :admin_id => '123', :message_type => 'comment', :body => 'bar')
# User (identified by email) replies with a comment and attachment
intercom.conversations.reply(:id => conversation.id, :type => 'user', :email => 'joe@example.com', :message_type => 'comment', :body => 'foo', :attachment => ['http://www.example.com/attachment.jpg'])

# Open
intercom.conversations.open(id: conversation.id, admin_id: '123')

# Close
intercom.conversations.close(id: conversation.id, admin_id: '123')

# Assign
intercom.conversations.assign(id: conversation.id, admin_id: '123', assignee_id: '124')

# Reply and Open
intercom.conversations.reply(:id => conversation.id, :type => 'admin', :admin_id => '123', :message_type => 'open', :body => 'bar')

# Reply and Close
intercom.conversations.reply(:id => conversation.id, :type => 'admin', :admin_id => '123', :message_type => 'close', :body => 'bar')

# ASSIGNING CONVERSATIONS TO ADMINS
intercom.conversations.reply(:id => conversation.id, :type => 'admin', :assignee_id => assignee_admin.id, :admin_id => admin.id, :message_type => 'assignment')

# MARKING A CONVERSATION AS READ
intercom.conversations.mark_read(conversation.id)
```

#### Full loading of an embedded entity
```ruby
# Given a conversation with a partial user, load the full user. This can be
# done for any entity
intercom.users.load(conversation.user)
```

#### Sending messages
```ruby

# InApp message from admin to user
intercom.messages.create({
  :message_type => 'inapp',
  :body => "What's up :)",
  :from => {
    :type => 'admin',
    :id   => "1234"
  },
  :to => {
    :type => "user",
    :id   => "5678"
  }
})

# Email message from admin to user
intercom.messages.create({
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
intercom.messages.create({
  :from => {
    :type => "user",
    :id => "536e564f316c83104c000020"
  },
  :body => "halp"
})

# Message from admin to contact

intercom.messages.create({
  :body     => "How can I help :)",
  :from => {
    :type => "admin",
    :id   => "1234"
  },
  :to => {
    :type => "contact",
    :id => "536e5643as316c83104c400671"
  }
})

# Message from a contact
intercom.messages.create({
  :from => {
    :type => "contact",
    :id => "536e5643as316c83104c400671"
  },
  :body => "halp"
})
```

#### Events
```ruby
intercom.events.create(
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
intercom.events.create(:event_name => "placed-order", :email => current_user.email,
  :created_at => 1403001013,
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

*NB:* This version of the gem reserves the field name `type` in Event data.

Bulk operations.
```ruby
# Submit bulk job, to create events
intercom.events.submit_bulk_job(create_items: [
  {
    event_name: "ordered-item",
    created_at: 1438944980,
    user_id: "314159",
    metadata: {
      order_date: 1438944980,
      stripe_invoice: "inv_3434343434"
    }
  },
  {
    event_name: "invited-friend",
    created_at: 1438944979,
    user_id: "314159",
    metadata: {
      invitee_email: "pi@example.org",
      invite_code: "ADDAFRIEND"
    }
  }
])


# Submit bulk job, to add items to existing job
intercom.events.submit_bulk_job(create_items: [
  {
    event_name: "ordered-item",
    created_at: 1438944980,
    user_id: "314159",
    metadata: {
      order_date: 1438944980,
      stripe_invoice: "inv_3434343434"
    }
  },
  {
    event_name: "invited-friend",
    created_at: 1438944979,
    user_id: "314159",
    metadata: {
      invitee_email: "pi@example.org",
      invite_code: "ADDAFRIEND"
    }
  }
], job_id:'job_abcd1234')
```

### Contacts

`Contacts` represent logged out users of your application.

```ruby
# Create a contact
contact = intercom.contacts.create(email: "some_contact@example.com")

# Update a contact
contact.custom_attributes['foo'] = 'bar'
intercom.contacts.save(contact)

# Find contacts by email
contacts = intercom.contacts.find_all(email: "some_contact@example.com")

# Convert a contact into a user
intercom.contacts.convert(contact, user)

# Delete a contact
intercom.contacts.delete(contact)
```

### Counts

```ruby
# App-wide counts
intercom.counts.for_app

# Users in segment counts
intercom.counts.for_type(type: 'user', count: 'segment')
```

### Subscriptions

Subscribe to events in Intercom to receive webhooks.

```ruby
# create a subscription
intercom.subscriptions.create(:url => "http://example.com", :topics => ["user.created"])

# fetch a subscription
intercom.subscriptions.find(:id => "nsub_123456789")

# list subscriptions
intercom.subscriptions.all
```
### Bulk jobs

```ruby
# fetch a job
intercom.jobs.find(id: 'job_abcd1234')

# fetch a job's error feed
intercom.jobs.errors(id: 'job_abcd1234')
```

### Errors

There are different styles for error handling - some people prefer exceptions; some prefer nil and check; some prefer error objects/codes. Balancing these preferences alongside our wish to provide an idiomatic gem has brought us to use the current mechanism of throwing specific exceptions. Our approach in the client is to propagate errors and signal our failure loudly so that erroneous data does not get propagated through our customers' systems - in other words, if you see a `Intercom::ServiceUnavailableError` you know where the problem is.

You do not need to deal with the HTTP response from an API call directly. If there is an unsuccessful response then an error that is a subclass of Intercom:Error will be raised. If desired, you can get at the http_code of an Intercom::Error via its `http_code` method.

The list of different error subclasses are listed below. As they all inherit off Intercom::IntercomError you can choose to rescue Intercom::IntercomError or
else rescue the more specific error subclass.

```ruby
Intercom::AuthenticationError
Intercom::ServerError
Intercom::ServiceUnavailableError
Intercom::ServiceConnectionError
Intercom::ResourceNotFound
Intercom::BadRequestError
Intercom::RateLimitExceeded
Intercom::AttributeNotSetError # Raised when you try to call a getter that does not exist on an object
Intercom::MultipleMatchingUsersError
Intercom::HttpError # Raised when response object is unexpectedly nil
```

### Rate Limiting

Calling your client's `rate_limit_details` returns a Hash that contains details about your app's current rate limit.

```ruby
intercom.rate_limit_details
#=> {:limit=>180, :remaining=>179, :reset_at=>2014-10-07 14:58:00 +0100}
```
