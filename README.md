# Experimental so far, api.intercom.io isn't public yet.

## Usage

```
Intercom.app_id = "my_app_id"
Intercom.secret_key = "my-super-crazy-secret"

user = Intercom::User.new(
  :email => 'joe@example.com'
  ...
)
user.save

...

user = Intercom::User.find(:email => 'joe@example.com')
```