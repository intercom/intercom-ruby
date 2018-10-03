# intercom-ruby

Ruby bindings for the Intercom API (https://developers.intercom.io/reference).

[API Documentation](https://developers.intercom.io/docs)

[Gem Documentation](http://rubydoc.info/github/intercom/intercom-ruby/master/frames)

For generating Intercom javascript script tags for Rails, please see https://github.com/intercom/intercom-rails.

## Upgrading information

Version 3 of intercom-ruby is not backwards compatible with previous versions.

Version 3 moves away from a global setup approach to the use of an Intercom Client.

This version of the gem is compatible with `Ruby 2.1` and above.

## Installation

    gem install intercom

Using bundler:

    gem 'intercom', '~> 3.6.1'

## Basic Usage

### Configure your client

> If you already have a personal access token you can find it [here](https://app.intercom.io/developers/_/access-token). If you want to create or learn more about personal access tokens then you can find more info [here](https://developers.intercom.io/docs/personal-access-tokens).

```ruby
# With an OAuth or Personal Access token:
intercom = Intercom::Client.new(token: 'my_token')
```

If you are building a third party application you can get your access_tokens by [setting-up-oauth](https://developers.intercom.io/page/setting-up-oauth) for Intercom.
You can also use the [omniauth-intercom lib](https://github.com/intercom/omniauth-intercom) which is a middleware helping you to handle the authentication process with Intercom.

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

### Examples

#### Users

```ruby
# Find user by email
user = intercom.users.find(email: "bob@example.com")
# Find user by user_id
user = intercom.users.find(user_id: "1")
# Find user by id
user = intercom.users.find(id: "1")
# Create a user
user = intercom.users.create(email: "bob@example.com", name: "Bob Smith", signed_up_at: Time.now.to_i)
# Delete a user
user = intercom.users.find(id: "1")
deleted_user = intercom.users.delete(user)
# Update custom_attributes for a user
user.custom_attributes["average_monthly_spend"] = 1234.56
intercom.users.save(user)
# Perform incrementing
user.increment('karma')
intercom.users.save(user)
# Perform decrementing
user.decrement('karma', 5)
intercom.users.save(user)
# Iterate over all users
intercom.users.all.each {|user| puts %Q(#{user.email} - #{user.custom_attributes["average_monthly_spend"]}) }
intercom.users.all.map {|user| user.email }
# List your users create in the last two days
intercom.users.find_all(type: 'users', page: 1, per_page: 10, created_since: 2, order: :asc).to_a.each_with_index {|usr, i| puts "#{i+1}: #{usr.name}"};
# Paginate through your list of users choosing how many to return per page (default and max is 50 per page)
intercom.users.find_all(type: 'users', page: 1, per_page: 10, order: :asc).to_a.each_with_index {|usr, i| puts "#{i+1}: #{usr.name}"}
# If you have over 10,000 users then you will need to use the scroll function to list your users
# otherwise you will encounter a page limit with list all your users
# You can use the scroll method to list all your users
intercom.users.scroll.each { |user| puts user.name}
# Alternatively you can use the scroll.next method to get 100 users with each request
result = intercom.users.scroll.next
# The result object then contains a records attributes that is an array of your user objects and it also contains a scroll_param which
# you can then use to request the next 100 users. Note that the scroll parameter will time out after one minute and you will need to
# make a new request
result.scroll_param
=> "0730e341-63ef-44da-ab9c-9113f886326d"
result = intercom.users.scroll.next("0730e341-63ef-44da-ab9c-9113f886326d");
```

#### Admins
```ruby
# Find access token owner (only with Personal Access Token and OAuth)
intercom.admins.me
# Find an admin by id
intercom.admins.find(id: admin_id)
# Iterate over all admins
intercom.admins.all.each {|admin| puts admin.email }
```

#### Companies
```ruby
# Add a user to one or more companies
user = intercom.users.find(email: "bob@example.com")
user.companies = [{company_id: 6, name: "Intercom"}, {company_id: 9, name: "Test Company"}]
intercom.users.save(user)
# You can also pass custom attributes within a company as you do this
user.companies = [{id: 6, name: "Intercom", custom_attributes: {referral_source: "Google"} } ]
intercom.users.save(user)
# Find a company by company_id
company = intercom.companies.find(company_id: "44")
# Find a company by name
company = intercom.companies.find(name: "Some company")
# Find a company by id
company = intercom.companies.find(id: "41e66f0313708347cb0000d0")
# Update a company
company.name = 'Updated company name'
intercom.companies.save(company)
# Iterate over all companies
intercom.companies.all.each {|company| puts %Q(#{company.name} - #{company.custom_attributes["referral_source"]}) }
intercom.companies.all.map {|company| company.name }
# Get a list of users in a company by Intercom Company ID
intercom.companies.users_by_intercom_company_id(company.id)
# Get a list of users in a company by external company_id
intercom.companies.users_by_company_id(company.company_id) 
# Get a large list of companies using scroll
intercom.companies.scroll.each { |comp| puts comp.name}
# Please see users scroll for more details of how to use scroll
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
tag = intercom.tags.tag(name: 'blue', companies: [{company_id: "42ea2f1b93891f6a99000427"}])
```

#### Segments
```ruby
# Find a segment
segment = intercom.segments.find(id: segment_id)
# Iterate over all segments
intercom.segments.all.each {|segment| puts "id: #{segment.id} name: #{segment.name}"}
```

#### Notes
```ruby
# Find a note by id
note = intercom.notes.find(id: note)
# Create a note for a user
note = intercom.notes.create(body: "<p>Text for the note</p>", email: 'joe@example.com')
# Iterate over all notes for a user via their email address
intercom.notes.find_all(email: 'joe@example.com').each {|note| puts note.body}
# Iterate over all notes for a user via their user_id
intercom.notes.find_all(user_id: '123').each {|note| puts note.body}
```

#### Conversations
```ruby
# Iterate over all conversations for your app
intercom.conversations.all.each { |convo| ... }

# FINDING CONVERSATIONS FOR AN ADMIN
# Iterate over all conversations (open and closed) assigned to an admin
intercom.conversations.find_all(type: 'admin', id: '7').each {|convo| ... }
# Iterate over all open conversations assigned to an admin
intercom.conversations.find_all(type: 'admin', id: 7, open: true).each {|convo| ... }
# Iterate over closed conversations assigned to an admin
intercom.conversations.find_all(type: 'admin', id: 7, open: false).each {|convo| ... }
# Iterate over closed conversations which are assigned to an admin, and where updated_at is before a certain moment in time
intercom.conversations.find_all(type: 'admin', id: 7, open: false, before: 1374844930).each {|convo| ... }

# FINDING CONVERSATIONS FOR A USER
# Iterate over all conversations (read + unread, correct) with a user based on the users email
intercom.conversations.find_all(email: 'joe@example.com', type: 'user').each {|convo| ... }
# Iterate over through all conversations (read + unread) with a user based on the users email
intercom.conversations.find_all(email: 'joe@example.com', type: 'user', unread: false).each {|convo| ... }
# Iterate over all unread conversations with a user based on the users email
intercom.conversations.find_all(email: 'joe@example.com', type: 'user', unread: true).each {|convo| ... }
# Iterate over all conversations for a user with their Intercom user ID
intercom.conversations.find_all(intercom_user_id: '536e564f316c83104c000020', type: 'user').each {|convo| ... }
# Iterate over all conversations for a lead 
# NOTE: to iterate over a lead's conversations you MUST use their Intercom User ID and type User
intercom.conversations.find_all(intercom_user_id: lead.id, type: 'user').each {|convo| ... }

# FINDING A SINGLE CONVERSATION
conversation = intercom.conversations.find(id: '1')

# INTERACTING WITH THE PARTS OF A CONVERSATION
# Getting the subject of a part (only applies to email-based conversations)
conversation.rendered_message.subject
# Get the part_type of the first part
conversation.conversation_parts[0].part_type
# Get the body of the second part
conversation.conversation_parts[1].body

# REPLYING TO CONVERSATIONS
# User (identified by email) replies with a comment
intercom.conversations.reply(id: conversation.id, type: 'user', email: 'joe@example.com', message_type: 'comment', body: 'foo')
# Admin (identified by id) replies with a comment
intercom.conversations.reply(id: conversation.id, type: 'admin', admin_id: '123', message_type: 'comment', body: 'bar')
# User (identified by email) replies with a comment and attachment
intercom.conversations.reply(id: conversation.id, type: 'user', email: 'joe@example.com', message_type: 'comment', body: 'foo', attachment_urls: ['http://www.example.com/attachment.jpg'])

# Open
intercom.conversations.open(id: conversation.id, admin_id: '123')

# Close
intercom.conversations.close(id: conversation.id, admin_id: '123')

# Assign
intercom.conversations.assign(id: conversation.id, admin_id: '123', assignee_id: '124')

# Reply and Open
intercom.conversations.reply(id: conversation.id, type: 'admin', admin_id: '123', message_type: 'open', body: 'bar')

# Reply and Close
intercom.conversations.reply(id: conversation.id, type: 'admin', admin_id: '123', message_type: 'close', body: 'bar')

# ASSIGNING CONVERSATIONS TO ADMINS
intercom.conversations.reply(id: conversation.id, type: 'admin', assignee_id: assignee_admin.id, admin_id: admin.id, message_type: 'assignment')

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
  message_type: 'inapp',
  body: "What's up :)",
  from: {
    type: 'admin',
    id: "1234"
  },
  to: {
    type: "user",
    user_id: "5678"
  }
})

# Email message from admin to user
intercom.messages.create({
  message_type: 'email',
  subject: 'Hey there',
  body: "What's up :)",
  template: "plain", # or "personal",
  from: {
    type: "admin",
    id: "1234"
  },
  to: {
    type: "user",
    id: "536e564f316c83104c000020"
  }
})

# Message from a user
intercom.messages.create({
  from: {
    type: "user",
    id: "536e564f316c83104c000020"
  },
  body: "halp"
})

# Message from admin to contact

intercom.messages.create({
  body: "How can I help :)",
  from: {
    type: "admin",
    id: "1234"
  },
  to: {
    type: "contact",
    id: "536e5643as316c83104c400671"
  }
})

# Message from a contact
intercom.messages.create({
  from: {
    type: "contact",
    id: "536e5643as316c83104c400671"
  },
  body: "halp"
})
```

#### Events
```ruby
intercom.events.create(
  event_name: "invited-friend",
  created_at: Time.now.to_i,
  email: user.email,
  metadata: {
    "invitee_email" => "pi@example.org",
    invite_code: "ADDAFRIEND",
    "found_date" => 12909364407
  }
)

# Retrieve event list for user with id:'123abc'
 intercom.events.find_all("type" => "user", "intercom_user_id" => "123abc")

```

Metadata Objects support a few simple types that Intercom can present on your behalf

```ruby
intercom.events.create(
  event_name: "placed-order",
  email: current_user.email,
  created_at: 1403001013,
  metadata: {
    order_date: Time.now.to_i,
    stripe_invoice: 'inv_3434343434',
    order_number: {
      value: '3434-3434',
      url: 'https://example.org/orders/3434-3434'
    },
    price: {
      currency: 'usd',
      amount: 2999
    }
  }
)
```

The metadata key values in the example are treated as follows-
- order_date: a Date (key ends with '_date')
- stripe_invoice: The identifier of the Stripe invoice (has a 'stripe_invoice' key)
- order_number: a Rich Link (value contains 'url' and 'value' keys)
- price: An Amount in US Dollars (value contains 'amount' and 'currency' keys)

*NB:* This version of the gem reserves the field name `type` in Event data.

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

# Using find to search for contacts by email
contact_list = intercom.contacts.find(email: "some_contact@example.com")
# This returns a Contact object with type contact.list
# Note: Multiple contacts can be returned in this list if there are multiple matching contacts found
# #<Intercom::Contact:0x00007ff3a80789f8
#   @changed_fields=#<Set: {}>,
#   @contacts=
#     [{"type"=>"contact",
#       "id"=>"5b7fd9b683681ac52274b9c7",
#       "user_id"=>"05bc4d17-72cc-433e-88ae-0bf88db5d0e6",
#       "anonymous"=>true,
#       "email"=>"some_contact@example.com",
#       ...}],
#   @custom_attributes={},
#   @limited=false,
#   @pages=#<Intercom::Pages:0x00007ff3a7413c58 @changed_fields=#<Set: {}>, @next=nil, @page=1, @per_page=50, @total_pages=1, @type="pages">,
#   @total_count=1,
#   @type="contact.list">
# Access the contact's data
contact_list.contacts.first

# Convert a contact into a user
contact = intercom.contacts.find(id: "536e564f316c83104c000020")
intercom.contacts.convert(contact, Intercom::User.new(email: email))
# Using find with email will not work here. See https://github.com/intercom/intercom-ruby/issues/419 for more information

# Delete a contact
intercom.contacts.delete(contact)

# Get a large list of contacts using scroll
intercom.contacts.scroll.each { |lead| puts lead.id}
# Please see users scroll for more details of how to use scroll
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
intercom.subscriptions.create(url: "http://example.com", topics: ["user.created"])

# fetch a subscription
intercom.subscriptions.find(id: "nsub_123456789")

# delete a subscription
subscription = intercom.subscriptions.find(id: "nsub_123456789")
intercom.subscriptions.delete(subscription)

# list subscriptions
intercom.subscriptions.all
```

### Errors

There are different styles for error handling - some people prefer exceptions; some prefer nil and check; some prefer error objects/codes. Balancing these preferences alongside our wish to provide an idiomatic gem has brought us to use the current mechanism of throwing specific exceptions. Our approach in the client is to propagate errors and signal our failure loudly so that erroneous data does not get propagated through our customers' systems - in other words, if you see a `Intercom::ServiceUnavailableError` you know where the problem is.

You do not need to deal with the HTTP response from an API call directly. If there is an unsuccessful response then an error that is a subclass of `Intercom::IntercomError` will be raised. If desired, you can get at the http_code of an `Intercom::IntercomError` via its `http_code` method.

The list of different error subclasses are listed below. As they all inherit off Intercom::IntercomError you can choose to rescue Intercom::IntercomError or else rescue the more specific error subclass.

```ruby
Intercom::AuthenticationError
Intercom::ServerError
Intercom::ServiceUnavailableError
Intercom::ServiceConnectionError
Intercom::ResourceNotFound
Intercom::BlockedUserError
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

You can handle the rate limits yourself but a simple option is to use the handle_rate_limit flag.
This will automatically catch the 429 rate limit exceeded error and wait until the reset time to retry. After three retries a rate limit exception will be raised. Encountering this error frequently may require a revisiting of your usage of the API.

```
intercom = Intercom::Client.new(token: ENV['AT'], handle_rate_limit: true)
```

### Pull Requests

- **Add tests!** Your patch won't be accepted if it doesn't have tests.

- **Document any change in behaviour**. Make sure the README and any other
  relevant documentation are kept up-to-date.

- **Create topic branches**. Don't ask us to pull from your master branch.

- **One pull request per feature**. If you want to do more than one thing, send
  multiple pull requests.

- **Send coherent history**. Make sure each individual commit in your pull
  request is meaningful. If you had to make multiple intermediate commits while
  developing, please squash them before sending them to us.
