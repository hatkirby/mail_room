# mail_room #

mail_room is a configuration based process that will idle on IMAP connections and POST to a delivery URL whenever a new message is received on the configured mailbox and folder.

[![Build Status](https://travis-ci.org/tpitale/mail_room.png?branch=master)](https://travis-ci.org/tpitale/mail_room)
[![Code Climate](https://codeclimate.com/github/tpitale/mail_room.png)](https://codeclimate.com/github/tpitale/mail_room)

## Installation ##

Add this line to your application's Gemfile:

    gem 'mail_room'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mail_room

You will also need to install `faraday` or `letter_opener` if you use the `postback` or `letter_opener` delivery methods, respectively.

## Usage ##

    mail_room -c /path/to/config.yml

## Configuration ##

```yaml
---
:mailboxes:
  -
    :email: "user1@gmail.com"
    :password: "password"
    :name: "inbox"
    :delivery_url: "http://localhost:3000/inbox"
    :delivery_token: "abcdefg"
    :search_command: 'NEW'
  -
    :email: "user2@gmail.com"
    :password: "password"
    :name: "inbox"
    :delivery_method: postback
    :delivery_url: "http://localhost:3000/inbox"
    :delivery_token: "abcdefg"
  -
    :email: "user3@gmail.com"
    :password: "password"
    :name: "inbox"
    :delivery_method: logger
    :log_path: "/var/log/user3-email.log"
  -
    :email: "user4@gmail.com"
    :password: "password"
    :name: "inbox"
    :delivery_method: letter_opener
    :location: "/tmp/user4-email"
```

## delivery_method ##

### postback ###

Requires `faraday` gem be installed.

*NOTE:* If you're using Ruby `>= 2.0`, you'll need to use Faraday from `>= 0.8.9`. Versions before this seem to have some weird behavior with `mail_room`.

The default delivery method, requires `delivery_url` and `delivery_token` in 
configuration.

As the postback is essentially using your app as if it were an API endpoint, 
you may need to disable forgery protection as you would with a JSON API. In 
our case, the postback is plaintext, but the protection will still need to be 
disabled.

### logger ###

Configured with `:delivery_method: logger`.

If `:log_path:` is not provided, defaults to `STDOUT`

### noop ###

Configured with `:delivery_method: noop`.

Does nothing, like it says.

### letter_opener ###

Requires `letter_opener` gem be installed.

Configured with `:delivery_method: letter_opener`.

Uses Ryan Bates' excellent [letter_opener](https://github.com/ryanb/letter_opener) gem.

## Gmail XOAUTH2 ##

If you are using Gmail and do not want to leave the password to your mailbox in a configuration file, `mail_room` can use OAuth to authenticate. To do so, you need to get a client ID/secret from Google, and generate a refresh token for the Gmail account you want to authenticate with. This also requires the `gmail_xoauth` and `oauth2` gems to be installed.

1. Go to the [Google APIs console](https://code.google.com/apis/console/), select "APIs & auth > Credentials", and click Create new Client ID.
2. Choose "Installed Application", and then "Other". If you are requested to set up a Consent screen, enter an email address and a product name, and continue.
3. Once you have a Client ID and Client secret, download the [oauth2.py tool](http://code.google.com/p/google-mail-oauth2-tools/wiki/OAuth2DotPyRunThrough).
4. `python oauth2.py --generate_oauth2_token --client_id=CLIENT_ID --client_secret=CLIENT_SECRET`
   
   Make sure to replace CLIENT_ID and CLIENT\_SECRET with the appropriate values.
5. Among the output will be a value labeled "refresh token". Use this and the client ID and secret to create a configuration file for `mail_drop`:

```yaml
---
:mailboxes:
  -
    :email: "user1@gmail.com"
    :auth_method: gmail_xoauth
    :refresh_token: "REFRESH_TOKEN"
    :client_id: "CLIENT_ID"
    :client_secret: "CLIENT_SECRET"
    :name: "inbox"
    :delivery_method: postback
    :delivery_url: "http://localhost:3000/inbox"
    :delivery_token: "abcdefg"
```

## Receiving `postback` in Rails ##

If you have a controller that you're sending to, with forgery protection
disabled, you can get the raw string of the email using `request.body.read`.

I would recommend having the `mail` gem bundled and parse the email using
`Mail.read_from_string(request.body.read)`.

## Search Command ##

This setting allows configuration of the IMAP search command sent to the server. This still defaults 'UNSEEN'. You may find that 'NEW' works better for you.

## IMAP Server Configuration ##

You can set per-mailbox configuration for the IMAP server's `host` (default: 'imap.gmail.com'), `port` (default: 993), and `ssl` (default: true).

## Running in Production ##

I suggest running with either upstart or init.d. Check out this wiki page for some example scripts for both: https://github.com/tpitale/mail_room/wiki/Init-Scripts-for-Running-mail_room

## Contributing ##

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
6. If accepted, ask for commit rights

## TODO ##

1. specs, this is just a (working) proof of concept √
2. finish code for POSTing to callback with auth √
3. accept mailbox configuration for one account directly on the commandline; or ask for it
4. add example rails endpoint, with auth examples
5. add example configs for upstart/init.d √
6. log to stdout √
7. add a development mode that opens in letter_opener by ryanb √
