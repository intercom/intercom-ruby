# Experimental so far, api.intercom.io isn't public yet.

Ruby bindings for the Intercom API (https://api.intercom.io).

TODO: link to more complete api docs with examples in each language.

## Usage

### Configure your access credentials

```
Intercom.app_id = "my_app_id"
Intercom.secret_key = "my-super-crazy-secret"
```

### Resources

All methods in this API operate in the context of a single user. Users are identified by either an '''email''' address or a '''user_id'''.
One of these is required as input to every operation.

#### Users

user = Intercom::User.find(params)
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
