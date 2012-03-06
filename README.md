Ruby bindings for the Intercom API (https://api.intercom.io). See http://docs.intercom.io/api for more details

## Install
```
gem install intercom
```

Using bundler:

```
gem 'intercom'
```

## Basic Usage

### Configure your access credentials

```
Intercom.app_id = "my_app_iddd"
Intercom.api_key = "my-super-crazy-api-key"
```

### Resources

The API supports:

```
POST,PUT,GET https://api.intercom.io/v1/users
POST,PUT,GET https://api.intercom.io/v1/users/messages
POST https://api.intercom.io/v1/users/impressions
```

#### Users

```ruby
user = Intercom::User.find(:email => "bob@example.com")
user = Intercom::User.create(params)
user = Intercom::User.new(params)
user.save
```

#### Messages

```ruby
Intercom::Message.create
Intercom::Message.find
Intercom::Message.find_all
Intercom::Message.mark_as_read
```

#### Impressions

```ruby
Intercom::Impression.create
```

### Errors

```ruby
Intercom::AuthenticationError
Intercom::ServerError
Intercom::ResourceNotFound
```
