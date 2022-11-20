# Mastodon on localhost The Easy Way

## Setup

```shell
docker-compose run --rm web bundle exec rake mastodon:setup
# Copy generated config into "env.production"
# Save generated admin password
```

Responses to the prompts:

| Prompt        | Answer        |
| ------------- | ------------- |
| Domain name:  | `localhost`  |
| Do you want to enable single user mode?  | N  |
| Are you using Docker to run Mastodon?  | Y  |
| PostgreSQL host:  | `db`  |
| PostgreSQL port:  | `5432`  |
| Name of PostgreSQL database:  | `postgres`  |
| Name of PostgreSQL user:  | `postgres`  |
| Password of PostgreSQL user:  | `postgres`  |
| Redis host:  | `redis`  |
| Redis port:  | `6379`  |
| Redis password:  | _blank_  |
| Do you want to store uploaded files on the cloud?  | N  |
| Do you want to send e-mails from localhost?  | Y  |
| E-mail address to send e-mails "from":  | _default_  |
| Send a test e-mail with this configuration right now?  | N  |
| Save configuration?  | Y  |
| Prepare the database now?  | Y  |
| Do you want to create an admin user straight away?  | Y  |
| Username:  | `admin`  |
| E-mail:  | `admin@localhost` |
| Do you want to create an admin user straight away?  | Y  |


Configure Nginx proxy:

```shell
cd nginx
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx-selfsigned.key -out nginx-selfsigned.crt
# Only set "Common Name" to "localhost"
docker build -f nginx.Dockerfile -t mastodon-nginx .
```

Start the whole thing:

```shell
docker-compose up
```

Open `https://localhost` (accept self-signed certificate), login with `admin@localhost` and password from earlier.

## API

Read timeline:

```shell
curl -k https://localhost/api/v1/timelines/public?limit=1 | jq .

[
  {
    "id": "109359509504193442",
    "created_at": "2022-11-17T14:01:27.512Z",
    "visibility": "public",
    "uri": "https://localhost/users/admin/statuses/109359509504193442",
    "url": "https://localhost/@admin/109359509504193442",
    "replies_count": 0,
    "reblogs_count": 0,
    "favourites_count": 0,
    "content": "<p>Test toot.</p>",
    "account": {
      "id": "109359234895957150",
      "username": "admin",
      "acct": "admin",
      "url": "https://localhost/@admin",
      "statuses_count": 1,
    },
  }
]
```

Create App/Bot:

```shell
curl -k -X POST \
	-F 'client_name=mastobot' \
	-F 'redirect_uris=urn:ietf:wg:oauth:2.0:oob' \
	-F 'scopes=read write follow push' \
	https://localhost/api/v1/apps | jq .

{
  "id": "1",
  "name": "mastobot",
  "website": null,
  "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
  "client_id": "...",
  "client_secret": "...",
  "vapid_key": ""
}
```

Authenticate bot:

```shell
curl -k -X POST \
	-F 'client_id=...' \
	-F 'client_secret=...' \
	-F 'redirect_uri=urn:ietf:wg:oauth:2.0:oob' \
	-F 'grant_type=client_credentials' \
	https://localhost/oauth/token | jq .

{
  "access_token": "...",
  "token_type": "Bearer",
  "scope": "read",
  "created_at": 1668694181
}
```

## Limitations

- No federation - can't search accounts/Toots from other instances
- No full-text search - can't search Toots (but can search hashtags and local accounts)

### Resources

- https://peterbabic.dev/blog/running-mastodon-with-docker-compose/