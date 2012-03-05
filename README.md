Ruby bindings for the Intercom API (https://api.intercom.io). See http://docs.intercom.io/api for more details

## Basic Usage

### Configure your access credentials

```
Intercom.app_id = "my_app_id"
Intercom.secret_key = "my-super-crazy-secret"
```

### Resources

All methods in this API operate in the context of a single user. Users are identified by either an '''email''' address or a '''user_id'''.
One of these is required as input to every operation.

#### Users

user = Intercom::User.find(:email => "bob@example.com")
user = Intercom::User.create(params)
user = Intercom::User.new(params)
user.save

#### Messages

Intercom::Message.create
Intercom::Message.find
Intercom::Message.find_all
Intercom::Message.mark_as_read

#### Impressions

Intercom::Impression.create

### Errors
