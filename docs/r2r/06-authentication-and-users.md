# R2R Authentication and User Management

## Overview

R2R provides comprehensive authentication and user management capabilities, enabling secure multi-user applications with role-based access control, email verification, and API key management.

## Core Concepts

### Users
- **User ID**: Unique identifier (UUID)
- **Email**: User email address (unique)
- **Username**: Optional username
- **Password**: Securely hashed
- **Verification Status**: Email verification state
- **Superuser Status**: Administrative privileges
- **Profile**: Name, bio, profile picture

### Authentication Methods
1. **Email/Password**: Traditional authentication
2. **API Keys**: Programmatic access
3. **JWT Tokens**: Stateless authentication
4. **Refresh Tokens**: Long-lived token renewal

### Roles
- **Regular User**: Standard access to owned resources
- **Superuser**: Administrative access to all resources

## Configuration

### Enable Authentication

Configure authentication in `r2r.toml`:

```toml
[auth]
provider = "r2r"
access_token_lifetime_in_minutes = 60
refresh_token_lifetime_in_days = 7
require_authentication = true
require_email_verification = true
default_admin_email = "admin@example.com"
default_admin_password = "change_me_immediately"
```

### Security Settings

```toml
[security]
require_authentication = true
require_email_verification = true
```

### Crypto Provider

```toml
[crypto]
provider = "bcrypt"
```

## User Registration

### Register User

**Endpoint:** `POST /v3/users`

Create a new user account.

#### Request Body

```json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "name": "John Doe",
  "bio": "AI researcher",
  "profile_picture": "https://example.com/avatar.jpg"
}
```

#### Response

```json
{
  "results": {
    "id": "user-123",
    "email": "user@example.com",
    "is_verified": false,
    "message": "User registered successfully. Please check your email for verification."
  }
}
```

#### Example: Python SDK

```python
from r2r import R2RClient

client = R2RClient()

# Register new user
client.register("me@email.com", "my_password")
```

### Email Verification

**Endpoint:** `POST /v3/users/verify-email`

Verify a user's email address.

#### Request Body

```json
{
  "email": "user@example.com",
  "verification_code": "verification-code-xyz"
}
```

#### Response

```json
{
  "message": "Email verified successfully."
}
```

#### Example: Python SDK

```python
# Verify email
client.verify_email("me@email.com", "my_verification_code")
```

### Send Verification Email

**Endpoint:** `POST /v3/users/send_verification_email`

Request a new verification email.

```python
# Resend verification email
client.send_verification_email()
```

## Authentication

### Login

**Endpoint:** `POST /v3/users/login`

Authenticate a user and receive access tokens.

#### Request Body

```json
{
  "username": "user@example.com",
  "password": "securepassword123"
}
```

#### Response

```json
{
  "access_token": "eyJhbGci...",
  "refresh_token": "def456...",
  "token_type": "bearer"
}
```

#### Example: Python SDK

```python
# Login
client.login("me@email.com", "my_password")
```

#### Example: cURL

```bash
curl -X POST "https://api.example.com/v3/users/login" \
     -H "Content-Type: application/json" \
     -d '{
       "username": "alice",
       "password": "securepassword123"
     }'
```

### Logout

**Endpoint:** `POST /v3/users/logout`

Invalidate the current user's tokens.

#### Response

```json
{
  "message": "Logged out successfully."
}
```

#### Example: Python SDK

```python
# Logout
client.logout()
```

### Refresh Token

**Endpoint:** `POST /v3/users/refresh-token`

Obtain a new access token using a refresh token.

#### Request Body

```json
{
  "refresh_token": "def456..."
}
```

#### Response

```json
{
  "access_token": "eyJhbGci..."
}
```

## Password Management

### Change Password

**Endpoint:** `POST /v3/users/change-password`

Change the authenticated user's password.

#### Request Body

```json
{
  "current_password": "oldpassword123",
  "new_password": "newsecurepassword456"
}
```

#### Response

```json
{
  "message": "Password changed successfully."
}
```

### Request Password Reset

**Endpoint:** `POST /v3/users/request-password-reset`

Initiate password reset process.

#### Request Body

```json
{
  "email": "user@example.com"
}
```

#### Response

```json
{
  "message": "Password reset email sent. Please check your inbox."
}
```

### Reset Password

**Endpoint:** `POST /v3/users/reset-password`

Reset password using a reset token.

#### Request Body

```json
{
  "reset_token": "reset-token-abc",
  "new_password": "newsecurepassword789"
}
```

#### Response

```json
{
  "message": "Password reset successfully."
}
```

## User Management

### Get Current User

**Endpoint:** `GET /v3/users/me`

Retrieve information about the authenticated user.

#### Response

```json
{
  "id": "user-123",
  "username": "alice",
  "email": "alice@example.com",
  "is_superuser": false,
  "created_at": "2023-10-27T10:00:00Z",
  "name": "Alice Smith",
  "bio": "AI Engineer",
  "profile_picture": "https://example.com/avatar.jpg"
}
```

#### Example: cURL

```bash
curl -X GET "https://api.example.com/v3/users/me" \
     -H "Authorization: Bearer YOUR_API_KEY"
```

### Get User by ID

**Endpoint:** `GET /v3/users/{id}`

Retrieve information about a specific user (requires appropriate permissions).

#### Response

```json
{
  "id": "user-789",
  "username": "charlie",
  "email": "charlie@example.com",
  "is_superuser": false,
  "created_at": "2023-10-26T15:30:00Z"
}
```

### List Users

**Endpoint:** `GET /v3/users`

List all users (superuser only).

#### Query Parameters

- **limit** (integer, optional): Number of users per page
- **offset** (integer, optional): Number of users to skip

#### Response

```json
{
  "users": [
    {
      "id": "user-123",
      "username": "alice",
      "email": "alice@example.com",
      "is_superuser": false
    },
    {
      "id": "user-456",
      "username": "bob",
      "email": "bob@example.com",
      "is_superuser": true
    }
  ]
}
```

### Update User

**Endpoint:** `POST /v3/users/{id}`

Update user information (users can update their own, superusers can update any).

#### Request Body

```json
{
  "username": "alice_updated",
  "email": "alice.new@example.com",
  "name": "Alice Johnson",
  "bio": "Senior AI Engineer",
  "is_superuser": false,
  "limits_overrides": {
    "max_documents": 500
  }
}
```

#### Response

```json
{
  "message": "User updated successfully."
}
```

#### Example: Python

```python
# Update user profile
client.users.update(
    user_id,
    email="newemail@example.com",
    name="Updated Name",
    bio="Updated bio"
)
```

### Delete User

**Endpoint:** `DELETE /v3/users/{id}`

Delete a user account (users can delete their own, superusers can delete any).

#### Request Body

```json
{
  "password": "current_password",
  "delete_vector_data": false
}
```

#### Response

```json
{
  "message": "User deleted successfully."
}
```

## API Key Management

### Create API Key

**Endpoint:** `POST /v3/users/{id}/api_keys`

Generate a new API key for a user.

#### Request Body

```json
{
  "name": "Production API Key",
  "description": "Key for production application"
}
```

#### Response

```json
{
  "api_key": "r2r_api_key_...",
  "key_id": "key-123",
  "name": "Production API Key",
  "created_at": "2024-01-15T10:00:00Z"
}
```

**Important:** Save the API key immediately. It cannot be retrieved later.

#### Example: Python

```python
# Create API key
api_key = client.users.create_api_key(
    user_id,
    name="My API Key",
    description="Key for automation"
)

print(f"API Key: {api_key['api_key']}")
```

### List API Keys

**Endpoint:** `GET /v3/users/{id}/api_keys`

List all API keys for a user.

#### Response

```json
{
  "api_keys": [
    {
      "key_id": "key-123",
      "name": "Production API Key",
      "created_at": "2024-01-15T10:00:00Z",
      "last_used_at": "2024-01-20T14:30:00Z"
    }
  ]
}
```

### Delete API Key

**Endpoint:** `DELETE /v3/users/{id}/api_keys/{key_id}`

Revoke an API key.

#### Response

```json
{
  "message": "API key deleted successfully."
}
```

#### Example: Python

```python
# Delete API key
client.users.delete_api_key(user_id, key_id)
```

## Collection Membership

### List User's Collections

**Endpoint:** `GET /v3/users/{id}/collections`

List all collections a user has access to.

#### Response

```json
{
  "collections": [
    {
      "id": "collection-abc",
      "name": "Research Papers"
    },
    {
      "id": "collection-def",
      "name": "Project Documents"
    }
  ]
}
```

#### Example: Python

```python
# Get user's collections
collections = client.users.list_collections(user_id)

for collection in collections["results"]:
    print(f"Collection: {collection['name']}")
```

### Add User to Collection

**Endpoint:** `POST /v3/users/{id}/collections/{collection_id}`

Grant user access to a collection.

#### Response

```json
{
  "message": "User added to collection successfully."
}
```

#### Example: Python

```python
# Add user to collection
client.collections.add_user(user_id, collection_id)
```

### Remove User from Collection

**Endpoint:** `DELETE /v3/users/{id}/collections/{collection_id}`

Revoke user access to a collection.

#### Response

```json
{
  "message": "User removed from collection successfully."
}
```

#### Example: Python

```python
# Remove user from collection
client.collections.remove_user(user_id, collection_id)
```

## Export Users

**Endpoint:** `POST /v3/users/export`

Export user data as CSV (superuser only).

#### Request Parameters

- **columns** (array, optional): Specific columns to export
- **filters** (object, optional): Filters to apply
- **include_header** (boolean, optional): Include headers (default: `true`)

## Permission Model

### Resource Ownership
Users can:
- View and modify their own resources
- Access collections they're members of
- Search within authorized collections

### Superuser Privileges
Superusers can:
- View and modify all users
- Access all collections
- Delete any resource
- Export system data
- Manage global settings

## Authentication Workflow

### Complete Registration Flow

```python
from r2r import R2RClient

client = R2RClient()

# 1. Register
client.register("user@example.com", "secure_password")

# 2. Verify email
# User receives email with verification code
client.verify_email("user@example.com", "verification_code")

# 3. Login
client.login("user@example.com", "secure_password")

# 4. Use authenticated endpoints
documents = client.documents.list()
```

### API Key Authentication

```python
from r2r import R2RClient

# Initialize with API key
client = R2RClient(
    base_url="http://localhost:7272",
    api_key="r2r_api_key_..."
)

# No need to login
documents = client.documents.list()
```

### Token Refresh Flow

```python
# Tokens expire after configured lifetime
# Automatically refresh when needed

try:
    results = client.retrieval.search("query")
except AuthenticationError:
    # Token expired, refresh
    client.refresh_token()
    results = client.retrieval.search("query")
```

## Best Practices

### 1. Use Strong Passwords

Enforce password requirements:
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, symbols
- Avoid common passwords

### 2. Enable Email Verification

```toml
[auth]
require_email_verification = true
```

### 3. Rotate API Keys Regularly

```python
# Create new key
new_key = client.users.create_api_key(user_id, name="Rotated Key")

# Update application configuration
# ...

# Delete old key
client.users.delete_api_key(user_id, old_key_id)
```

### 4. Use Environment Variables

Never hardcode credentials:

```bash
export R2R_API_KEY=r2r_api_key_...
export R2R_BASE_URL=http://localhost:7272
```

```python
import os
from r2r import R2RClient

client = R2RClient(
    base_url=os.getenv("R2R_BASE_URL"),
    api_key=os.getenv("R2R_API_KEY")
)
```

### 5. Implement Token Refresh Logic

Handle token expiration gracefully:

```python
from r2r import R2RClient
from r2r.exceptions import AuthenticationError

def make_request_with_retry(client, operation):
    try:
        return operation()
    except AuthenticationError:
        client.refresh_token()
        return operation()

# Usage
results = make_request_with_retry(
    client,
    lambda: client.retrieval.search("query")
)
```

### 6. Audit User Access

Regularly review user permissions:

```python
# Superuser only
users = client.users.list()

for user in users:
    collections = client.users.list_collections(user["id"])
    print(f"User {user['email']}: {len(collections)} collections")
```

### 7. Limit Superuser Accounts

Only grant superuser status when necessary:

```python
# Create regular user (default)
client.register("user@example.com", "password")

# Grant superuser (admin only)
client.users.update(
    user_id,
    is_superuser=True
)
```

## Troubleshooting

### Authentication Failed

Check:
1. Credentials are correct
2. User email is verified (if required)
3. User account is not locked
4. Tokens haven't expired

### Email Not Received

Solutions:
1. Check spam folder
2. Verify email configuration in `r2r.toml`
3. Resend verification email
4. Check email provider settings

### Token Expired

```python
# Refresh token
client.refresh_token()

# Or re-login
client.login("user@example.com", "password")
```

### Permission Denied

Verify:
1. User has access to the resource
2. User is member of the collection
3. Operation is allowed for user role

## Resources

- [R2R Authentication API Reference](https://r2r-docs.sciphi.ai/api/auth)
- [User Management Guide](https://r2r-docs.sciphi.ai/features/users)
- [Security Best Practices](https://r2r-docs.sciphi.ai/security)
