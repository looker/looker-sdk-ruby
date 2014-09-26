## How to authenticate to Looker's API 3

The preferred way to authenticate is to use the looker SDK to manage the login and the passing of
access_tokens as needed. This doc, however, explains how to do this authentication in a generic way without the SDK and using curl instead for illustration.

Looker API 3 implements OAuth 2's "Resource Owner Password Credentials Grant" pattern,
See: http://tools.ietf.org/html/rfc6749#section-4.3

### Setup an API key
An 'API 3' key is required in order to login and use the API. The key consists of a client_id and a client_secret.
'Login' consists of using these credentials to generate a short-term access_token which is then used to make API calls.

The client_id could be considered semi-public. While, the client_secret is a secret password and MUST be
carefully protected. These credentials should not be hard-coded into client code. They should be read from
a closely guarded data file when used by client processes.

Admins can create an API 3 key for a user on looker's user edit page. All requests made using these
credentials are made 'as' that user and limited to the role permissions specified for that user. A user
account with an appropriate role may be created as needed for the API client's use.

Note that API 3 tokens should be created for 'regular' Looker users and *not* via the legacy 'Add API User' button.


### Ensure that the API is accessible
Looker versions 3.4 (and beyond) expose the 3.0 API via a port different from the port used by the web app.
The default port is 19999. It may be necessary to have the Ops team managing the looker instance ensure that this
port is made accessible network-wise to client software running on non-local hosts.

The '/alive' url can be used to detect if the server is reachable


### Login
To access the API it is necessary to 'login' using the client_id and client_secret in order to acquire an
access_token that will be used in actual API requests. This is done by POSTing to the /login url. The access_token is returned in a short json body and has a limited time before it expires (the default at this point is 1 hour).
An 'expires_in' field is provided to tell client software how long they should expect the token to last.

A new token is created for each /login call and remains valid until it expires or is revoked via /logout.

It is VERY important that these tokens never be sent in the clear or exposed in any other way.


### Call the API
API calls then pass the access_token to looker using an 'Authorization' header. API calls are
done using GET, PUT, POST, PATCH, or DELETE as appropriate for the specific call. Normal REST stuff.


### Logout
A '/logout' url is available if the client wants to revoke an access_token. It requires a DELETE request.
Looker reserves the right to limit the number of 'live' access_tokens per user.

-------------------------------------------------------------------------------------------------

The following is an example session using Curl. The '-i' param is used to show returned headers.

The simple flow in this example is to login, get info about the current user, then logout.

Note that in this example the client_id and client_secret params are passed using '-d' which causes the
request to be done as a POST. And, the -H param is used to specify http headers to add for API requests.

```
# Check that the port is reachable
> curl -i https://localhost:19999/alive
HTTP/1.1 200 OK
Content-Type: application/json;charset=utf-8
Vary: Accept-Encoding
X-Content-Type-Options: nosniff
Content-Length: 0


# Do the login to get an access_token
> curl -i  -d "client_id=4j3SD8W5RchHw5gvZ5Yd&client_secret=sVySctSMpQQG3TzdNQ5d2dND"  https://localhost:19999/login
HTTP/1.1 200 OK
Content-Type: application/json;charset=utf-8
Vary: Accept-Encoding
X-Content-Type-Options: nosniff
Content-Length: 99

{"access_token":"4QDkCyCtZzYgj4C2p2cj3csJH7zqS5RzKs2kTnG4","token_type":"Bearer","expires_in":3600}

# Use an access_token (the token can be used over and over for API calls until it expires)
> curl -i -H "Authorization: token 4QDkCyCtZzYgj4C2p2cj3csJH7zqS5RzKs2kTnG4"  https://localhost:19999/api/3.0/user
HTTP/1.1 200 OK
Content-Type: application/json;charset=utf-8
Vary: Accept-Encoding
X-Content-Type-Options: nosniff
Content-Length: 502

{"id":14,"first_name":"Plain","last_name":"User","email":"dude+1@looker.com","models_dir":null,"is_disabled":false,"look_access":[14],"avatar_url":"https://www.gravatar.com/avatar/b7f792a6180a36a4058f36875584bc45?s=156&d=mm","credentials_email":{"email":"dude+1@looker.com","url":"https://localhost:19999/api/3.0/users/14/credentials_email","user_url":"https://localhost:19999/api/3.0/users/14","password_reset_url":"https://localhost:19999/api/3.0"},"url":"https://localhost:19999/api/3.0/users/14"}

# Logout to revoke an access_token
> curl -i -X DELETE -H "Authorization: token 4QDkCyCtZzYgj4C2p2cj3csJH7zqS5RzKs2kTnG4"  https://localhost:19999/logout
HTTP/1.1 200 OK
Content-Type: application/json;charset=utf-8
Vary: Accept-Encoding
X-Content-Type-Options: nosniff
Content-Length: 0

# Show that the access_token is no longer valid
> curl -i -X DELETE -H "Authorization: token 4QDkCyCtZzYgj4C2p2cj3csJH7zqS5RzKs2kTnG4"  https://localhost:19999/logout
HTTP/1.1 404 Not Found
Content-Type: application/json;charset=utf-8
Vary: Accept-Encoding
X-Content-Type-Options: nosniff
Content-Length: 69

{"message":"Not found","documentation_url":"http://docs.looker.com/"}
```
