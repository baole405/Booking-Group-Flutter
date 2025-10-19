# Mobile API Guide (Flutter Consumer)

This short document lists the backend REST endpoints that the mobile Flutter
client can call after the Render deployment is live. Focus is on the flows
available to authenticated students (group members and leaders).

---
## deploy BE:  https://swd392-exe-team-management-be.onrender.com/swagger-ui/index.html#/

## 1. Base Configuration

- **Base URL**: `https://<your-render-service>.onrender.com/api`
- **Content type**: `application/json`
- **Auth header**: `Authorization: Bearer <jwt-token>`
- All responses share the envelope described in [`ERROR_FORMAT.md`](ERROR_FORMAT.md):

```json
{
  "status": 200,
  "message": "Get my info successfully",
  "data": { ... }      // may be null on errors
}
```

## 2. Login Flow (Google Sign-In)

1. Use `google_sign_in` (or Firebase Auth) in Flutter to fetch an **ID token**.
2. Send the token to the backend:

```http
POST /api/auth/google-login
Content-Type: application/json

{ "idToken": "<google-id-token>" }
```

3. Backend response (`AuthResponse`) contains the JWT:

```json
{
  "status": 200,
  "message": "Google login success",
  "data": {
    "email": "user@example.com",
    "token": "<jwt-token>"
  }
}
```

4. Store the JWT securely (e.g., `flutter_secure_storage`) and attach it to all
subsequent API calls via the `Authorization` header.

### Flutter helper snippet (Dio)

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://<your-render-service>.onrender.com/api',
  headers: {'Content-Type': 'application/json'},
));

Future<void> loginWithGoogle(String idToken) async {
  final res = await dio.post('/auth/google-login', data: {'idToken': idToken});
  final payload = res.data['data'];
  final token = payload['token'] as String;
  dio.options.headers['Authorization'] = 'Bearer $token';
}
```

---

## 3. Endpoint Catalogue (User-Facing)

| Method | Path | Purpose | Notes |
| ------ | ---- | ------- | ----- |
| `GET` | `/auth/google-login` | _n/a_ | Use `POST` only; here for completeness. |
| `POST` | `/auth/google-login` | Exchange Google ID token for backend JWT | No auth required. |

### 3.1 User Profile

| Method | Path | Purpose | Roles |
| ------ | ---- | ------- | ----- |
| `GET` | `/users/myInfo` | Get current user's full profile | Any logged-in user. |
| `PUT` | `/users/myInfo` | Update current user's profile (`UserUpdateRequest`) | Any logged-in user. |
| `GET` | `/users/{id}` | View another user's profile | Any logged-in user. |
| `GET` | `/users` | Search users with filters | Mainly admin/moderator; mobile may use for global lookup. |

### 3.2 Group Management

| Method | Path | Purpose | Notes |
| ------ | ---- | ------- | ----- |
| `GET` | `/groups/my-group` | Fetch the group the current user belongs to | Students/leaders. |
| `GET` | `/groups/{groupId}` | Group details by id | |
| `GET` | `/groups/{groupId}/members` | List members | |
| `GET` | `/groups/{groupId}/leader` | Get group leader | |
| `GET` | `/groups/{groupId}/members/count` | Member count | |
| `GET` | `/groups/{groupId}/majors` | Major distribution (`Major` entities) | |
| `GET` | `/groups/available` | Groups the current user can join | |
| `GET` | `/groups/semester/{semesterId}` | All groups in a semester | |
| `PATCH` | `/groups/change-type` | Leader toggles PUBLIC/PRIVATE | Leader only. |
| `PATCH` | `/groups/done` | Leader finalizes team (exact member count met) | Leader only. |
| `PATCH` | `/groups/change-leader/{newLeaderId}` | Transfer leadership | Leader only. |
| `PUT` | `/groups/update` | Update title/description | Leader only. |
| `DELETE` | `/groups/members/{userId}` | Remove member from group | Leader only. |
| `DELETE` | `/groups/leave` | Leave current group | Any member; leadership reassignment handled server-side. |

> `POST /groups` (create empty groups) exists but is intended for admin tools, not general mobile users.

### 3.3 Join Requests & Voting

| Method | Path | Purpose | Notes |
| ------ | ---- | ------- | ----- |
| `POST` | `/joins/{groupId}` | Request to join a group | Behavior depends on group status (auto-join / pending vote). |
| `GET` | `/joins/my-requests` | Current user's pending join requests | |
| `GET` | `/joins/{groupId}/pending` | Pending requests for a group | Visible to group members. |
| `DELETE` | `/joins/{joinId}` | Cancel own join request | |
| `POST` | `/votes/join/{groupId}/{userId}` | Trigger vote for a user to join | Usually auto-called by backend; keep documented for admin tools. |
| `POST` | `/votes/{voteId}/choice?choiceValue=YES|NO` | Submit vote choice | Group members only. |
| `GET` | `/votes/{voteId}` | Vote details | |
| `GET` | `/votes/{voteId}/choices` | How members voted | |
| `GET` | `/votes/group/{groupId}` | All votes for a group | |
| `GET` | `/votes/open` | All open votes | |
| `PATCH` | `/votes/{voteId}/finalize` | Manually close vote | Primarily moderator/admin. |

### 3.4 Ideas (Project Proposals)

| Method | Path | Purpose | Notes |
| ------ | ---- | ------- | ----- |
| `POST` | `/ideas` | Leader creates idea (`IdeaRequest`) | |
| `PUT` | `/ideas/{id}` | Update idea | Allowed when status is DRAFT or REJECTED. |
| `DELETE` | `/ideas/{id}` | Delete idea | Leader/admin. |
| `GET` | `/ideas/{id}` | Idea detail | |
| `GET` | `/ideas/group/{groupId}` | Ideas for a group | |
| `GET` | `/ideas` | All ideas | Admin/teacher overview. |
| `PATCH` | `/ideas/{id}/submit` | Submit idea (DRAFT → PROPOSED) | Leader. |
| `PATCH` | `/ideas/{id}/approve` | Approve idea (PROPOSED → APPROVED) | Teacher. |
| `PATCH` | `/ideas/{id}/reject?reason=...` | Reject idea with reason | Teacher. |

### 3.5 Recruitment Posts & Comments

| Method | Path | Purpose | Notes |
| ------ | ---- | ------- | ----- |
| `POST` | `/posts` | Create recruitment post (`PostRequest`) | For leaders (find member) or students (find group). |
| `GET` | `/posts` | List all posts | |
| `GET` | `/posts/{id}` | Post detail | |
| `GET` | `/posts/type/{type}` | Filter posts by `FIND_MEMBER` or `FIND_GROUP` | |
| `PUT` | `/posts/{id}` | Update own post | Owner only. |
| `DELETE` | `/posts/{id}` | Delete own post | Owner only. |
| `POST` | `/comments` | Create comment (`CommentRequest`) | Requires auth. |
| `PUT` | `/comments/{id}` | Update own comment | Owner or admin. |
| `DELETE` | `/comments/{id}` | Delete comment | Owner/admin. |
| `GET` | `/comments/{id}` | Comment detail | |
| `GET` | `/comments/post/{postId}` | Comments under a post | |
| `GET` | `/comments` | All comments | Admin/moderator scope. |

### 3.6 Notifications

| Method | Path | Purpose | Notes |
| ------ | ---- | ------- | ----- |
| `GET` | `/notifications` | List notifications for current user | Newest first. |
| `PATCH` | `/notifications/{notificationId}/read` | Mark as read | Owner only. |

### 3.7 Supporting Catalog Data

| Method | Path | Purpose | Notes |
| ------ | ---- | ------- | ----- |
| `GET` | `/majors` | List majors for filtering | |
| `GET` | `/majors/{id}` | Major detail | |
| `GET` | `/semesters` | All semesters | Shows active flag. |
| `GET` | `/semesters/{id}` | Semester detail | |

> `POST/PUT/DELETE` on majors and semesters exist but require admin privileges and are typically not exposed to mobile users.

---

## 4. Error Handling Tips

- When `status` is not `2xx`, inspect `message` for the localized reason.
- Validation errors return a `data` object containing field-level messages.
- Common HTTP codes: `400` (bad request), `401` (missing/invalid token), `403`
  (not allowed for current role), `404` (resource not found), `500` (server
  issue).

Sample Flutter guard:

```dart
Future<Response<T>> safeRequest<T>(Future<Response<T>> call) async {
  try {
    final res = await call;
    if (res.data is Map && (res.data as Map)['status'] != 200) {
      throw ApiException(res.data['message']);
    }
    return res;
  } on DioException catch (e) {
    final backend = e.response?.data;
    final message = backend is Map ? backend['message'] : e.message;
    throw ApiException(message ?? 'Unexpected error');
  }
}
```

---

## 5. Next Steps for Mobile Integration

1. Add `.env` entry (or constants) for the Render base URL and inject into your
   networking layer.
2. Implement an auth interceptor to inject the JWT and refresh it when login
   succeeds.
3. Map the backend DTOs (`UserResponse`, `GroupResponse`, etc.) to Dart models
   that mirror the JSON under `data`.
4. Reuse the endpoint tables above when building feature-specific repositories
   or services in the Flutter codebase.

Happy coding!
