# intercom-ruby

[![Circle CI](https://circleci.com/gh/intercom/intercom-ruby.png?style=shield)](https://circleci.com/gh/intercom/intercom-ruby)
[![gem](https://img.shields.io/gem/v/intercom)](https://rubygems.org/gems/intercom)
![Intercom API Version](https://img.shields.io/badge/Intercom%20API%20Version-2.6-blue)

> Ruby bindings for the [Intercom API](https://developers.intercom.io/reference).

## Project Update

### Maintenance

We're currently building a new team to provide in-depth and dedicated SDK support.

In the meantime, we'll be operating on limited capacity, meaning all pull requests will be evaluated on a best effort basis and will be limited to critical issues.

We'll communicate all relevant updates as we build this new team and support strategy in the coming months.

[API Documentation](https://developers.intercom.io/docs)

[Gem Documentation](http://rubydoc.info/github/intercom/intercom-ruby/master/frames)

For generating Intercom JavaScript script tags for Rails, please see [intercom/intercom-rails](https://github.com/intercom/intercom-rails)

## Upgrading information

Version 4 of intercom-ruby is not backwards compatible with previous versions. Please see our [migration guide](https://github.com/intercom/intercom-ruby/wiki/Migration-guide-for-v4) for full details of breaking changes.

This version of the gem is compatible with `Ruby 2.1` and above.

## Installation

```bash
gem install intercom
```

Using bundler:

```bundler
gem 'intercom', '~> 4.1'
```

## Basic Usage

### Configure your client

> If you already have a personal access token you can find it [here](https://app.intercom.io/a/apps/_/developer-hub/). If you want to create or learn more about personal access tokens then you can find more info [here](https://developers.intercom.io/docs/personal-access-tokens).

```ruby
# With an OAuth or Personal Access token:
intercom = Intercom::Client.new(token: 'my_token')
```

```ruby
# With a versioned app:
intercom = Intercom::Client.new(token: 'my_token', api_version: '2.2')
```

If you are building a third party application you can get your access_tokens by [setting-up-oauth](https://developers.intercom.io/page/setting-up-oauth) for Intercom.
You can also use the [omniauth-intercom lib](https://github.com/intercom/omniauth-intercom) which is a middleware helping you to handle the authentication process with Intercom.

### Resources

Resources this API supports:

```text
https://api.intercom.io/contacts
https://api.intercom.io/visitors
https://api.intercom.io/companies
https://api.intercom.io/data_attributes
https://api.intercom.io/events
https://api.intercom.io/tags
https://api.intercom.io/notes
https://api.intercom.io/segments
https://api.intercom.io/conversations
https://api.intercom.io/messages
https://api.intercom.io/admins
https://api.intercom.io/teams
https://api.intercom.io/counts
https://api.intercom.io/subscriptions
https://api.intercom.io/jobs
https://api.intercom.io/articles
https://api.intercom.io/help_center/collections
https://api.intercom.io/help_center/sections
https://api.intercom.io/phone_call_redirects
https://api.intercom.io/subscription_types
https://api.intercom.io/export/content/data
```

### Examples

#### Contacts

Note that this is a new resource compatible only with the new [Contacts API](https://developers.intercom.com/intercom-api-reference/reference#contacts-model) released in API v2.0.

```ruby
# Create a contact with "lead" role
contact = intercom.contacts.create(email: "some_contact2@example.com", role: "lead")

# Get a single contact using their intercom_id
intercom.contacts.find(id: contact.id)

# Update a contact
contact.name = "New name"
intercom.contacts.save(contact)

# Update a contact's role from "lead" to "user"
contact.role = "user"
intercom.contacts.save(contact)

# Archive a contact
intercom.contacts.archive(contact)

# Unarchive a contact
intercom.contacts.unarchive(contact)

# Delete a contact permanently
intercom.contacts.delete(contact)

# Deletes an archived contact permanently
intercom.contacts.delete_archived_contact(contact.id)

# List all contacts
contacts = intercom.contacts.all
contacts.each { |contact| p contact.name }

# Search for contacts by email
contacts = intercom.contacts.search(
  "query": {
    "field": 'email',
    "operator": '=',
    "value": 'some_contact@example.com'
  }
)
contacts.each {|c| p c.email}
# For full detail on possible queries, please refer to the API documentation:
# https://developers.intercom.com/intercom-api-reference/reference

# Merge a lead into an existing user
lead = intercom.contacts.create(email: "some_contact2@example.com", role: "lead")
intercom.contacts.merge(lead, intercom.contacts.find(id: "5db2e80ab1b92243d2188cfe"))

# Add a tag to a contact
tag = intercom.tags.find(id: "123")
contact.add_tag(id: tag.id)

# Remove a tag
contact.remove_tag(id: tag.id)

# List tags for a contact
contact.tags.each {|t| p t.name}

# Create a note on a contact
contact.create_note(body: "<p>Text for the note</p>")

# List notes for a contact
contact.notes.each {|n| p n.body}

# List segments for a contact
contact.segments.each {|segment| p segment.name}

# Add a contact to a company
company = intercom.companies.find(id: "123")
contact.add_company(id: company.id)

# Remove a contact from a company
contact.remove_company(id: company.id)

# List companies for a contact
contact.companies.each {|c| p c.name}

# attach a subscription_types on a contact
contact.create_subscription_type(id: subscription_type.id)

# List subscription_types for a contact
contact.subscription_types.each {|n| p n.id}

# Remove subscription_types
contact.remove_subscription_type({ "id": subscription_type.id })

```

#### Visitors

```ruby
# Get and update a visitor
visitor = intercom.visitors.find(id: "5dd570e7b1b922452676af23")
visitor.name = "New name"
intercom.visitors.save(visitor)

# Convert a visitor into a lead
intercom.visitors.convert(visitor)

# Convert a visitor into a user
user = intercom.contacts.find(id: "5db2e7f5b1b92243d2188cb3")
intercom.visitors.convert(visitor, user)
```

#### Companies

```ruby
# Find a company by company_id
company = intercom.companies.find(company_id: "44")

# Find a company by name
company = intercom.companies.find(name: "Some company")

# Find a company by id
company = intercom.companies.find(id: "41e66f0313708347cb0000d0")

# Update a company
company.name = 'Updated company name'
intercom.companies.save(company)

# Delete a company
intercom.companies.delete(company)

# Iterate over all companies
intercom.companies.all.each {|company| puts %Q(#{company.name} - #{company.custom_attributes["referral_source"]}) }
intercom.companies.all.map {|company| company.name }

# Get a large list of companies using scroll
intercom.companies.scroll.each { |comp| puts comp.name}
# Please see users scroll for more details of how to use scroll
```

#### Data Attributes

Data Attributes are a type of metadata used to describe your customer and company models. These include standard and custom attributes.

```ruby
# Create a new custom data attribute
intercom.data_attributes.create({ name: "test_attribute", model: "contact", data_type: "string" })

# List all data attributes
attributes = intercom.data_attributes.all
attributes.each { |attribute| p attribute.name }

# Update an attribute
attribute = intercom.data_attributes.all.first
attribute.label = "New label"
intercom.data_attributes.save(attribute)

# Archive an attribute
attribute.archived = true
intercom.data_attributes.save(attribute)

# Find all customer attributes including archived
customer_attributes_incl_archived = intercom.data_attributes.find_all({"model": "contact", "include_archived": true})
customer_attributes_incl_archived.each { |attr| p attr.name }
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

# Alternatively, use "user_id" in case your app allows multiple accounts having the same email
intercom.events.create(
  event_name: "invited-friend",
  created_at: Time.now.to_i,
  user_id: user.uuid,
)

# Retrieve event list for user with id:'123abc'
 intercom.events.find_all("type" => "user", "intercom_user_id" => "123abc")

# Retrieve the event summary for user with id: 'abc' this will return an event object with the following characteristics:
# name - name of the event
# first - time when event first occured.
# last - time when event last occured
# count - number of times the event occured
# description -  description of the event
 events = intercom.events.find_all(type: 'user',intercom_user_id: 'abc',summary: true)
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

The metadata key values in the example are treated as follows:

- order_date: a Date (key ends with '_date')
- stripe_invoice: The identifier of the Stripe invoice (has a 'stripe_invoice' key)
- order_number: a Rich Link (value contains 'url' and 'value' keys)
- price: An Amount in US Dollars (value contains 'amount' and 'currency' keys)

*NB:* This version of the gem reserves the field name `type` in Event data.

#### Tags

```ruby
# Iterate over all tags
intercom.tags.all.each {|tag| "#{tag.id} - #{tag.name}" }
intercom.tags.all.map {|tag| tag.name }

# Tag companies
tag = intercom.tags.tag(name: 'blue', companies: [{company_id: "42ea2f1b93891f6a99000427"}])

# Untag Companies
tag = intercom.tags.untag(name: 'blue', companies: [{ company_id: "42ea2f1b93891f6a99000427" }])


# Delete Tags

# Note : If there any depedent objects for the tag we are trying to delete, then an error TagHasDependentObjects will be thrown.
tag = intercom.tags.find(id:"123")
intercom.tags.delete(tag)
```

#### Notes

```ruby
# Find a note by id
note = intercom.notes.find(id: "123")
```

#### Segments

```ruby
# Find a segment
segment = intercom.segments.find(id: segment_id)

# Iterate over all segments
intercom.segments.all.each {|segment| puts "id: #{segment.id} name: #{segment.name}"}
```

#### Conversations

```ruby
# Iterate over all conversations for your app
intercom.conversations.all.each { |convo| ... }

# The below method of finding conversations by using the find_all method work only for API versions 2.5 and below

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
conversation.source.subject

# Get the part_type of the first part
conversation.conversation_parts.first.part_type

# Get the body of the second part
conversation.conversation_parts[1].body

# Get statistics related to the conversation
conversation.statistics.time_to_admin_reply
conversation.statistics.last_assignment_at

# Get information on the sla applied to a conversation
conversation.sla_applied.sla_name

# REPLYING TO CONVERSATIONS
# User (identified by email) replies with a comment
intercom.conversations.reply(id: conversation.id, type: 'user', email: 'joe@example.com', message_type: 'comment', body: 'foo')
# Admin (identified by id) replies with a comment
intercom.conversations.reply(id: conversation.id, type: 'admin', admin_id: '123', message_type: 'comment', body: 'bar')
# User (identified by email) replies with a comment and attachment
intercom.conversations.reply(id: conversation.id, type: 'user', email: 'joe@example.com', message_type: 'comment', body: 'foo', attachment_urls: ['http://www.example.com/attachment.jpg'])

#reply to a user's last conversation
intercom.conversations.reply_to_last(type: 'user', body: 'Thanks again', message_type: 'comment', user_id: '12345', admin_id: '123')

# Open
intercom.conversations.open(id: conversation.id, admin_id: '123')

# Close
intercom.conversations.close(id: conversation.id, admin_id: '123')

# Assign
# Note: Conversations can be assigned to teams. However, the entity that performs the operation of assigning the conversation has to be an existing teammate.
#       You can use `intercom.admins.all.each {|a| puts a.inspect if a.type == 'admin' }` to list all of your teammates.
intercom.conversations.assign(id: conversation.id, admin_id: '123', assignee_id: '124')

# Snooze
intercom.conversations.snooze(id: conversation.id, admin_id: '123', snoozed_until: 9999999999)

# Reply and Open
intercom.conversations.reply(id: conversation.id, type: 'admin', admin_id: '123', message_type: 'open', body: 'bar')

# Reply and Close
intercom.conversations.reply(id: conversation.id, type: 'admin', admin_id: '123', message_type: 'close', body: 'bar')

# Admin reply to last conversation
intercom.conversations.reply_to_last(intercom_user_id: '5678', type: 'admin', admin_id: '123', message_type: 'comment', body: 'bar')

# User reply to last conversation
intercom.conversations.reply_to_last(intercom_user_id: '5678', type: 'user', message_type: 'comment', body: 'bar')

# ASSIGNING CONVERSATIONS TO ADMINS
intercom.conversations.reply(id: conversation.id, type: 'admin', assignee_id: assignee_admin.id, admin_id: admin.id, message_type: 'assignment')

# MARKING A CONVERSATION AS READ
intercom.conversations.mark_read(conversation.id)

# RUN ASSIGNMENT RULES
intercom.conversations.run_assignment_rules(conversation.id)

# Search for conversations
# For full detail on possible queries, please refer to the API documentation:
# https://developers.intercom.com/intercom-api-reference/reference

# Search for open conversations sorted by the created_at date
conversations = intercom.conversations.search(
  query: {
    field: "open",
    operator: "=",
    value: true
  },
  sort_field: "created_at",
  sort_order: "descending"
)
conversations.each {|c| p c.id}

# Tagging for conversations
tag = intercom.tags.find(id: "2")
conversation = intercom.conversations.find(id: "1")

# An Admin ID is required to add or remove tag on a conversation
admin = intercom.admins.find(id: "1")

# Add a tag to a conversation
conversation.add_tag(id: tag.id, admin_id: admin.id)

# Remove a tag from a conversation
conversation.remove_tag(id: tag.id, admin_id: admin.id)

# Add a contact to a conversation
conversation.add_contact(admin_id: admin.id, customer: { intercom_user_id: contact.id })

# Remove a contact from a conversation
conversation.remove_contact(id: contact.id, admin_id: admin.id)
```

#### Full loading of an embedded entity

```ruby
# Given a conversation with a partial contact, load the full contact. This can be
# done for any entity
intercom.contacts.load(conversation.contacts.first)
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

#From version 2.6 the type contact is not supported and you would have to use leads to send messages to a lead.

intercom.messages.create({
  from: {
    type: "lead",
    id: "536e5643as316c83104c400671"
  },
  body: "halp"
})
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

#### Teams

```ruby
# Find a team by id
intercom.teams.find(id: team_id)
# Iterate over all teams
intercom.teams.all.each {|team| puts team.name }
```

#### Counts

```ruby
# App-wide counts
intercom.counts.for_app

# Users in segment counts
intercom.counts.for_type(type: 'user', count: 'segment')
```

#### Subscriptions

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


#### Subscription Types

List all the subscription types that a contact can opt in to

```ruby

# fetch a subscription
intercom.subscription_types.find(id: "1")

intercom.subscription_types.all
```

#### Articles

```ruby
# Create an article
article = intercom.articles.create(title: "New Article", author_id: "123456")

# Create an article with translations
article = intercom.articles.create(title: "New Article",
                                   author_id: "123456",
                                   translated_content: {fr: {title: "Nouvel Article"}, es: {title: "Nuevo artículo"}})

# Fetch an article
intercom.articles.find(id: "123456")

# List all articles
articles = intercom.articles.all
articles.each { |article| p article.title }

# Update an article
article.title = "Article Updated!"
intercom.articles.save(article)

# Update an article's existing translation
article.translated_content.en.title = "English Updated!"
intercom.articles.save(article)

# Update an article by adding a new translation
article.translated_content.es = {title: "Artículo en español"}
intercom.articles.save(article)

# Delete an article
intercom.articles.delete(article)
```

#### Collections

```ruby
# Create a collection
collection = intercom.collections.create(name: "New Collection")

# Create a collection with translations
collection = intercom.collections.create(name: "New Collection",
                                         translated_content: {fr: {name: "Nouvelle collection"}, es: {name: "Nueva colección"}})

# Fetch a collection
intercom.collections.find(id: "123456")

# List all collections
collections = intercom.collections.all
collections.each { |collection| p collection.name }

# Update a collection
collection.name = "Collection updated!"
intercom.collections.save(collection)

# Update a collection's existing translation
collection.translated_content.en.name = "English Updated!"
intercom.collections.save(collection)

# Update a collection by adding a new translation
collection.translated_content.es = {name: "Colección en español", description: "Descripción en español"}
intercom.collections.save(collection)

# Delete an collection
intercom.collections.delete(collection)
```

#### Sections

```ruby
# Create a section
section = intercom.sections.create(name: "New Section", parent_id: "123456")

# Create a section with translations
section = intercom.sections.create(name: "New Section",
                                   translated_content: {fr: {name: "Nouvelle section"}, es: {name: "Nueva sección"}})

# Fetch a section
intercom.sections.find(id: "123456")

# List all sections
sections = intercom.sections.all
sections.each { |section| p section.name }

# Update a section
section.name = "Section updated!"
intercom.sections.save(section)

# Update a section's existing translation
section.translated_content.en.name = "English Updated!"
intercom.collections.save(section)

# Update a section by adding a new translation
section.translated_content.es = {name: "Sección en español"}
intercom.collections.save(section)

# Delete an section
intercom.sections.delete(section)
```

#### Phone Call Redirect (switch)

```ruby
# Create a redirect
redirect = intercom.phone_call_redirect.create(phone_number: "+353871234567")

```

#### Data Content Export

```ruby
# Create a data export
export = intercom.export_content.create(created_at_after: 1667566801, created_at_before: 1668085202)


#View a data export
export = intercom.export_content.find(id: 'k0e27ohsyvh8ef3m')

# Cancel a data export
export = intercom.export_content.cancel('k0e27ohsyvh8ef3m')

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
Intercom::GatewayTimeoutError
```

### Rate Limiting

Calling your client's `rate_limit_details` returns a Hash that contains details about your app's current rate limit.

```ruby
intercom.rate_limit_details
#=> {:limit=>180, :remaining=>179, :reset_at=>2014-10-07 14:58:00 +0100}
```

You can handle the rate limits yourself but a simple option is to use the handle_rate_limit flag.
This will automatically catch the 429 rate limit exceeded error and wait until the reset time to retry. After three retries a rate limit exception will be raised. Encountering this error frequently may require a revisiting of your usage of the API.

```ruby
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

### Development

#### Running tests

```bash
# all tests
bundle exec rake spec

# unit tests
bundle exec rake spec:unit

# integration tests
bundle exec rake spec:integration

# single test file
bundle exec m spec/unit/intercom/job_spec.rb

# single test
bundle exec m spec/unit/intercom/job_spec.rb:49
```
