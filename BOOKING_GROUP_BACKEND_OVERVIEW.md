# Booking Group Backend Overview

## Table of Contents
1. [Project Structure](#1-project-structure)
2. [Student & Leader API Summary](#2-student--leader-api-summary)
   1. [Authentication](#21-authentication)
   2. [User Profile](#22-user-profile)
   3. [Group Management](#23-group-management)
   4. [Join Requests & Voting](#24-join-requests--voting)
   5. [Posts & Comments](#25-posts--comments)
   6. [Notifications](#26-notifications)
3. [Domain Models & Relationships](#3-domain-models--relationships)
4. [Key Flows](#4-key-flows)
5. [Additional Notes & Caveats](#5-additional-notes--caveats)

## 1. Project Structure
- **Entry point & scheduling**: `src/main/java/com/swd/exe/teammanagement/ExeTeamManagementApplication.java` sets UTC timezone, loads `.env`, and enables schedulers before bootstrapping Spring Boot.【F:src/main/java/com/swd/exe/teammanagement/ExeTeamManagementApplication.java†L1-L18】
- **Configuration**: `config/` houses JWT, security, CORS, WebSocket, Firebase, Cloudinary, and dotenv helpers. `SecurityConfig` currently permits all `/api/**` requests while still wiring the JWT filter.【F:src/main/java/com/swd/exe/teammanagement/config/SecurityConfig.java†L16-L45】
- **Controllers/Services/Repositories**: REST entry points live in `controller/`, business logic in `service/impl/`, and Spring Data JPA interfaces in `repository/` (e.g., `GroupController`, `JoinServiceImpl`, `GroupRepository`).【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L35-L221】【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L24-L205】【F:src/main/java/com/swd/exe/teammanagement/repository/GroupRepository.java†L1-L7】
- **DTOs & Mappers**: Request/response payloads are under `dto/`, with MapStruct mappers in `mapper/` to transform entities to DTOs (e.g., `PostMapper`).【F:src/main/java/com/swd/exe/teammanagement/dto/ApiResponse.java†L1-L37】【F:src/main/java/com/swd/exe/teammanagement/mapper/PostMapper.java†L1-L40】
- **Entities & Enums**: Persistence models live in `entity/` (User, Group, Join, Post, Comment, Vote, etc.), with supporting enums (GroupStatus, MembershipRole, PostType, JoinStatus, VoteStatus/Choice).【F:src/main/java/com/swd/exe/teammanagement/entity/Group.java†L13-L44】【F:src/main/java/com/swd/exe/teammanagement/enums/group/GroupStatus.java†L1-L6】
- **Configuration files**: `src/main/resources/application.yml` pulls DB credentials and external service keys from environment variables; `.env` values are injected at startup via `DotenvLoader`.【F:src/main/resources/application.yml†L1-L35】【F:src/main/java/com/swd/exe/teammanagement/config/DotenvLoader.java†L5-L15】

## 2. Student & Leader API Summary
Unless stated otherwise, controllers wrap responses in `ApiResponse` with `status` 200 for success or 201 for creations.【F:src/main/java/com/swd/exe/teammanagement/dto/ApiResponse.java†L21-L33】 Despite `SecurityConfig` marking `/api/**` as permitted, most service methods expect an authenticated principal and will throw if the user cannot be resolved.【F:src/main/java/com/swd/exe/teammanagement/config/SecurityConfig.java†L30-L45】【F:src/main/java/com/swd/exe/teammanagement/service/impl/PostServiceImpl.java†L189-L193】

### 2.1 Authentication
| Method | Route | Handler | Access & Rules | Status / Errors | Main Flow |
| --- | --- | --- | --- | --- | --- |
| POST | `/api/auth/google-login` | `AuthController.googleLogin` → `AuthServiceImpl.loginWithGoogle` | Public; expects Google ID token. | `200` success. Throws `INVALID_GG_TOKEN`, `EMAIL_INVALID_FORMAT`.【F:src/main/java/com/swd/exe/teammanagement/controller/AuthController.java†L23-L31】【F:src/main/java/com/swd/exe/teammanagement/service/impl/AuthServiceImpl.java†L37-L90】 | Verifies token with Firebase, upserts user, auto-assigns role (admin/lecturer/student) based on email domain, issues JWT via `JwtService`, and seeds a “update your major” notification.【F:src/main/java/com/swd/exe/teammanagement/service/impl/AuthServiceImpl.java†L72-L154】【F:src/main/java/com/swd/exe/teammanagement/config/JwtService.java†L19-L43】

### 2.2 User Profile
| Method | Route | Handler | Access & Rules | Status / Errors | Main Flow |
| --- | --- | --- | --- | --- | --- |
| GET | `/api/users/myInfo` | `UserController.getMyInfo` → `UserService.getMyInfo` | Requires authenticated user (looked up by email). | `200`; `USER_UNEXISTED` on missing profile.【F:src/main/java/com/swd/exe/teammanagement/controller/UserController.java†L63-L70】 | Returns current user’s profile DTO.
| PUT | `/api/users/myInfo` | `UserController.updateMyInfo` | Authenticated user; payload validated. | `200`; service enforces business validation. | Updates current user details via `UserService.updateMyInfo`.
| GET | `/api/users/{id}` | `UserController.getUserById` | Accessible to any caller; service throws if user missing. | `200`; `USER_UNEXISTED`.【F:src/main/java/com/swd/exe/teammanagement/controller/UserController.java†L33-L40】 | Fetches profile for others.
| GET | `/api/users` | `UserController.getAllUsers` | Supports filtering by query, role, active, major; primarily admin/teacher use. | `200`. | Delegates to `UserService.searchUsers` with paging params.【F:src/main/java/com/swd/exe/teammanagement/controller/UserController.java†L42-L61】
| PATCH | `/api/users/{id}` | `UserController.changeStatus` | Toggles `isActive`; likely admin-only but no explicit guard beyond service. | `200`; `USER_UNEXISTED`. | Calls `UserService.changeStatus`.
| PATCH | `/api/users/role/{id}` | `UserController.updateRoleForLecturer` | `@PreAuthorize` requires ADMIN role. | `200`; `ROLE_UPDATE_NOT_SWITCHABLE`. | Flips lecturer/moderator roles.【F:src/main/java/com/swd/exe/teammanagement/controller/UserController.java†L99-L107】
| POST | `/api/users/{id}/avatar` & `/cv` | Upload endpoints storing files (Cloudinary). | User must own targeted profile; throws on invalid file type. | `200`. | Delegates to `UserService.uploadAvatar/CV`.
| GET | `/api/users/no-group` | Returns students without group. | `200`. | Pulls from `UserService.getUserNoGroup`.【F:src/main/java/com/swd/exe/teammanagement/controller/UserController.java†L108-L120】

### 2.3 Group Management
| Method | Route | Handler | Access & Rules | Status / Errors | Main Flow |
| --- | --- | --- | --- | --- | --- |
| GET | `/api/groups/{id}` | `GroupController.getGroupById` | Open call; service throws if not found. | `200`; `GROUP_UNEXISTED`. | Maps entity to DTO.【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L44-L51】
| GET | `/api/groups/my-group` | Returns caller’s group; requires membership. | `200`; `USER_NOT_IN_GROUP`. | Uses authenticated email in `GroupService.getMyGroup` to find `GroupMember`.【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L80-L87】【F:src/main/java/com/swd/exe/teammanagement/service/impl/GroupServiceImpl.java†L238-L252】
| GET | `/api/groups/{groupId}/members|leader|majors|members/count` | Provide roster, leader, and major mix. | `200`; errors if group missing/leader missing. | Combine repository lookups for membership details.【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L89-L123】【F:src/main/java/com/swd/exe/teammanagement/service/impl/GroupServiceImpl.java†L113-L122】
| GET | `/api/groups/available` | Suggests joinable groups. | `200`. | Filters groups by status/major distribution so 6th member diversifies majors.【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L125-L132】【F:src/main/java/com/swd/exe/teammanagement/service/impl/GroupServiceImpl.java†L254-L280】
| PATCH | `/api/groups/change-type` | Leader-only; toggles PUBLIC/PRIVATE. | `200`; `USER_NOT_IN_GROUP`, `ONLY_GROUP_LEADER`. | Switches `Group.type` via service.【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L134-L150】【F:src/main/java/com/swd/exe/teammanagement/service/impl/GroupServiceImpl.java†L254-L270】
| PATCH | `/api/groups/done` | Leader finalizes team. | `200`; fails if not leader, group lacks diversity (≥2 majors) or size bounds (1–6). | Sets status to `LOCKED`, deactivates recruitment posts.【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L152-L160】【F:src/main/java/com/swd/exe/teammanagement/service/impl/GroupServiceImpl.java†L282-L303】
| PATCH | `/api/groups/change-leader/{newLeaderId}` | Leader-only; requires target in same group. | `200`; `ONLY_GROUP_LEADER`, `USER_NOT_IN_GROUP`, `CANNOT_TRANSFER_TO_SELF`. | Swaps membership roles for leader/member entries.【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L162-L170】【F:src/main/java/com/swd/exe/teammanagement/service/impl/GroupServiceImpl.java†L200-L213】
| DELETE | `/api/groups/leave` | Member/leader leaves. | `200`; resets empty groups to FORMING, otherwise transfers leadership to next member. | Also deactivates join records for departing user.【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L172-L180】【F:src/main/java/com/swd/exe/teammanagement/service/impl/GroupServiceImpl.java†L238-L349】
| DELETE | `/api/groups/members/{userId}` | Leader-only removal. | `200`; ensures target is active member. | Deactivates member and associated joins.【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L182-L190】【F:src/main/java/com/swd/exe/teammanagement/service/impl/GroupServiceImpl.java†L193-L233】
| PUT | `/api/groups/update` | Leader updates title/description. | `200`; `ONLY_GROUP_LEADER`. | Persisted via `GroupService.updateGroupInfo`.【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L192-L199】
| POST | `/api/groups?size&semesterId` | Admin/ops utility to seed empty FORMING groups. | `201`; validates semester active. | Iteratively creates `Group` rows with status FORMING and PUBLIC type.【F:src/main/java/com/swd/exe/teammanagement/controller/GroupController.java†L201-L209】【F:src/main/java/com/swd/exe/teammanagement/service/impl/GroupServiceImpl.java†L305-L327】

### 2.4 Join Requests & Voting
| Method | Route | Handler | Access & Rules | Status / Errors | Main Flow |
| --- | --- | --- | --- | --- | --- |
| POST | `/api/joins/{groupId}` | `JoinController.joinGroup` → `JoinServiceImpl.joinGroup` | Authenticated student only (throws if already in group or major missing). | `201`; `USER_ALREADY_IN_GROUP`, `GROUP_LOCKED`, `UPDATE_MAJOR`. | FORMING group: promotes caller to leader, switches group to ACTIVE, auto-creates accepted join record (enforces “first member becomes leader”). Active & PUBLIC: adds as MEMBER and notifies existing members. Otherwise falls back to `joinRequest` (pending vote) and deactivates caller’s posts.【F:src/main/java/com/swd/exe/teammanagement/controller/JoinController.java†L25-L33】【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L38-L106】
| GET | `/api/joins/{groupId}/pending` | List pending join requests for a group. | `200`; requires group exist. | Returns `Join` entities with `JoinStatus.PENDING` for leader/member review.【F:src/main/java/com/swd/exe/teammanagement/controller/JoinController.java†L35-L43】【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L138-L143】
| GET | `/api/joins/my-requests` | Caller’s outstanding join requests. | `200`. | Filters `Join` by current user and `PENDING` status.【F:src/main/java/com/swd/exe/teammanagement/controller/JoinController.java†L45-L52】
| DELETE | `/api/joins/{joinId}` | Cancel pending join. | `200`; `UNAUTHORIZED` if not owner, `JOIN_REQUEST_ALREADY_PROCESSED` if resolved. | Removes join record.【F:src/main/java/com/swd/exe/teammanagement/controller/JoinController.java†L55-L63】【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L151-L164】
| POST | `/api/votes/join/{groupId}/{userId}` | `VoteController.createVoteJoin` | Typically triggered when leader wants vote on candidate (also auto-called by `joinRequest`). | `201`; `GROUP_NOT_FOUND`, `USER_UNEXISTED`. | Creates `Vote` with 24h deadline and `VoteStatus.OPEN`. No guard prevents duplicate votes per candidate.【F:src/main/java/com/swd/exe/teammanagement/controller/VoteController.java†L27-L38】【F:src/main/java/com/swd/exe/teammanagement/service/impl/VoteServiceImpl.java†L38-L62】
| POST | `/api/votes/{voteId}/choice?choiceValue=YES|NO` | Submit vote choice. | `201`; lacks duplicate prevention despite `ErrorCode.DUPLICATE_VOTE`. | Saves vote choice for current user without verifying group membership or unique ballot.【F:src/main/java/com/swd/exe/teammanagement/controller/VoteController.java†L40-L51】【F:src/main/java/com/swd/exe/teammanagement/service/impl/VoteServiceImpl.java†L64-L84】
| PATCH | `/api/votes/{voteId}/finalize` | Manually close vote. | `200`. | Calls `voteDone`, which counts YES vs NO, adds member on approval, updates join status, or marks rejected; scheduler auto-closes once all votes in or deadline passed.【F:src/main/java/com/swd/exe/teammanagement/controller/VoteController.java†L93-L101】【F:src/main/java/com/swd/exe/teammanagement/service/impl/VoteServiceImpl.java†L86-L181】
| GET | `/api/votes/{voteId}` / `/choices` / `/open` / `/group/{groupId}` | Reporting endpoints for votes and ballots. | `200`. | Pulls vote metadata and choice lists for UI status boards.【F:src/main/java/com/swd/exe/teammanagement/controller/VoteController.java†L53-L90】

**Notifications on join lifecycle**: `JoinServiceImpl` emits system and JOIN_REQUEST/JOIN_ACCEPTED notifications to involved users for direct joins and vote-triggered requests.【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L68-L105】【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L117-L135】 Vote acceptance/rejection currently updates `Join` status but WebSocket notifications are commented out.【F:src/main/java/com/swd/exe/teammanagement/service/impl/VoteServiceImpl.java†L95-L150】

### 2.5 Posts & Comments
| Method | Route | Handler | Access & Rules | Status / Errors | Main Flow |
| --- | --- | --- | --- | --- | --- |
| POST | `/api/posts` | `PostController.createPost` → `PostServiceImpl.createPost` | Students without group may publish `FIND_GROUP`; group leaders may publish `FIND_MEMBER`. Prevents multiple active posts per user/group. | `201`; errors: `USER_ALREADY_IN_GROUP`, `POST_ALREADY_ACTIVE`, `USER_NOT_IN_GROUP`, `ONLY_GROUP_LEADER`. | Stores post tied to user (find group) or group (find member) and activates it. Group posts do not attach a `user`, so clients should expect `userResponse` = null.【F:src/main/java/com/swd/exe/teammanagement/controller/PostController.java†L38-L45】【F:src/main/java/com/swd/exe/teammanagement/service/impl/PostServiceImpl.java†L38-L72】
| GET | `/api/posts` / `/{id}` / `/type/{type}` | Fetch posts or filter by `PostType` (`FIND_GROUP`, `FIND_MEMBER`). | `200`; `POST_UNEXISTED`. | Uses repository + mappers to assemble DTOs.【F:src/main/java/com/swd/exe/teammanagement/controller/PostController.java†L65-L90】
| PUT | `/api/posts/{id}` | Update existing post. | `200`; forbids editing other users’ posts. Leaders can update any post if they hold leader role, even across groups (potential issue). | Updates content only.【F:src/main/java/com/swd/exe/teammanagement/controller/PostController.java†L102-L108】【F:src/main/java/com/swd/exe/teammanagement/service/impl/PostServiceImpl.java†L133-L159】
| DELETE | `/api/posts/{id}` | Soft delete (set `active=false`). | `200`; ensures only owner or owning group’s leader can deactivate. | Deactivates but retains record.【F:src/main/java/com/swd/exe/teammanagement/controller/PostController.java†L92-L100】【F:src/main/java/com/swd/exe/teammanagement/service/impl/PostServiceImpl.java†L103-L125】

**Comments**
| Method | Route | Handler | Notes |
| --- | --- | --- | --- |
| POST | `/api/comments` | `CommentController.createComment` → `CommentServiceImpl.createComment` | Authenticated user posts comment; timestamp set to now. | `201`; `POST_UNEXISTED` if parent missing.【F:src/main/java/com/swd/exe/teammanagement/controller/CommentController.java†L23-L30】【F:src/main/java/com/swd/exe/teammanagement/service/impl/CommentServiceImpl.java†L31-L40】
| PUT / DELETE | `/api/comments/{id}` | Only comment owner may update/delete (admin bypass promised in docstring but not implemented). | `200`; `DOES_NOT_DELETE_OTHER_USER_POST`. | Update resets `createdAt` rather than tracking `updatedAt`.【F:src/main/java/com/swd/exe/teammanagement/controller/CommentController.java†L31-L47】【F:src/main/java/com/swd/exe/teammanagement/service/impl/CommentServiceImpl.java†L48-L71】
| GET | `/api/comments/{id}` / `/post/{postId}` / (all) | Retrieval endpoints for comment threads. | `200`; `COMMENT_UNEXISTED`. | Maps to DTO list.【F:src/main/java/com/swd/exe/teammanagement/controller/CommentController.java†L48-L70】

### 2.6 Notifications
| Method | Route | Handler | Access & Rules | Status / Errors | Main Flow |
| --- | --- | --- | --- | --- | --- |
| GET | `/api/notifications` | `NotificationController.getMyNotifications` | Requires authenticated email; returns notifications sorted descending. | `200`; `USER_UNEXISTED`. | Delegates to `NotificationServiceImpl.getMyNotifications`.【F:src/main/java/com/swd/exe/teammanagement/controller/NotificationController.java†L31-L40】【F:src/main/java/com/swd/exe/teammanagement/service/impl/NotificationServiceImpl.java†L31-L49】
| PATCH | `/api/notifications/{id}/read` | Mark as read. | `200`; throws `UNAUTHORIZED` if caller not receiver. | Sets status to `READ`.【F:src/main/java/com/swd/exe/teammanagement/controller/NotificationController.java†L42-L55】【F:src/main/java/com/swd/exe/teammanagement/service/impl/NotificationServiceImpl.java†L31-L42】

## 3. Domain Models & Relationships
- **User**: core profile with optional `studentCode`, `major`, and `role` (`STUDENT`, `LECTURER`, `MODERATOR`, `ADMIN`).【F:src/main/java/com/swd/exe/teammanagement/entity/User.java†L11-L42】【F:src/main/java/com/swd/exe/teammanagement/enums/user/UserRole.java†L1-L7】
- **Group**: stores title, description, `GroupType` (`PUBLIC`/`PRIVATE`), `GroupStatus` (`FORMING`, `ACTIVE`, `LOCKED`), semester relation, `createdAt`, and `active` flag.【F:src/main/java/com/swd/exe/teammanagement/entity/Group.java†L21-L44】【F:src/main/java/com/swd/exe/teammanagement/enums/group/GroupType.java†L1-L5】【F:src/main/java/com/swd/exe/teammanagement/enums/group/GroupStatus.java†L1-L6】
- **GroupMember**: join table mapping users to groups with `MembershipRole` (`LEADER`, `MEMBER`) and `active` flag.【F:src/main/java/com/swd/exe/teammanagement/entity/GroupMember.java†L16-L33】【F:src/main/java/com/swd/exe/teammanagement/enums/user/MembershipRole.java†L1-L5】
- **Join**: represents membership history/requests with `JoinStatus` (`PENDING`, `ACCEPTED`, `REJECTED`) and `active`. Used both for accepted entries and pending votes.【F:src/main/java/com/swd/exe/teammanagement/entity/Join.java†L16-L31】【F:src/main/java/com/swd/exe/teammanagement/enums/idea_join_post_score/JoinStatus.java†L1-L5】
- **Vote/VoteChoice**: voting sessions around join approvals. `Vote` links to `Group` and `targetUser` with status `OPEN`/`CLOSED`, while `VoteChoice` records each member’s `ChoiceValue` (`YES`, `NO`).【F:src/main/java/com/swd/exe/teammanagement/entity/Vote.java†L18-L38】【F:src/main/java/com/swd/exe/teammanagement/entity/VoteChoice.java†L18-L34】【F:src/main/java/com/swd/exe/teammanagement/enums/vote/VoteStatus.java†L1-L5】【F:src/main/java/com/swd/exe/teammanagement/enums/vote/ChoiceValue.java†L1-L5】
- **Post & Comment**: recruitment posts (FIND_GROUP/FIND_MEMBER) optionally linked to a group, with textual comments attached.【F:src/main/java/com/swd/exe/teammanagement/entity/Post.java†L18-L39】【F:src/main/java/com/swd/exe/teammanagement/enums/idea_join_post_score/PostType.java†L1-L5】【F:src/main/java/com/swd/exe/teammanagement/entity/Comment.java†L17-L34】
- **Notification**: stored alerts with `NotificationType` and read/unread status; generated during authentication, join events, etc.【F:src/main/java/com/swd/exe/teammanagement/entity/Notification.java†L19-L38】【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L68-L135】

**Leader-on-first-member rule**: Enforced in `JoinServiceImpl.joinGroup`—when a user joins a `FORMING` group, the group transitions to `ACTIVE`, and a new `GroupMember` record is created with `MembershipRole.LEADER`. This automatically satisfies “first member becomes leader.”【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L52-L68】

## 4. Key Flows
1. **Leader recruits via post → student responds → invite/vote**
   - Leader ensures they’re leader of a group, then posts `FIND_MEMBER` via `POST /api/posts` (validated against duplicate active posts).【F:src/main/java/com/swd/exe/teammanagement/service/impl/PostServiceImpl.java†L55-L70】
   - Interested student comments using `POST /api/comments`; only author can later edit/delete their comment.【F:src/main/java/com/swd/exe/teammanagement/service/impl/CommentServiceImpl.java†L31-L55】
   - Because no dedicated invite API exists, leader must trigger membership by either sharing group ID for the student to call `POST /api/joins/{groupId}` or create a vote manually via `/api/votes/join/{groupId}/{userId}`. The join request path notifies existing members and opens a vote for approval.【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L103-L135】【F:src/main/java/com/swd/exe/teammanagement/service/impl/VoteServiceImpl.java†L38-L118】

2. **Student browses group detail & requests to join**
   - Student fetches available groups via `/api/groups/available` (filtered for diversity/slots).【F:src/main/java/com/swd/exe/teammanagement/service/impl/GroupServiceImpl.java†L254-L280】
   - Student hits `POST /api/joins/{groupId}`. Behaviour depends on group:
     - `FORMING`: student becomes leader, group switches to `ACTIVE` (no vote needed).【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L52-L71】
     - `ACTIVE` + `PUBLIC`: joins immediately as `MEMBER`, notifications broadcasted.【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L73-L101】
     - Otherwise (e.g., `PRIVATE` or locked-like scenario): creates `JoinStatus.PENDING` and kicks off vote/notifications.【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L103-L135】

3. **Approval workflow**
   - Pending joins surface via `/api/joins/{groupId}/pending`. Members can view vote progress via `/api/votes/group/{groupId}` and `/choices` endpoints.【F:src/main/java/com/swd/exe/teammanagement/controller/JoinController.java†L35-L43】【F:src/main/java/com/swd/exe/teammanagement/controller/VoteController.java†L53-L90】
   - Votes close automatically once everyone votes or deadline passes (scheduler in `VoteServiceImpl.autoCloseVotes`).【F:src/main/java/com/swd/exe/teammanagement/service/impl/VoteServiceImpl.java†L153-L182】 Approved candidates are added to `GroupMember` and their join status flips to `ACCEPTED`; rejections mark `JoinStatus.REJECTED`.【F:src/main/java/com/swd/exe/teammanagement/service/impl/VoteServiceImpl.java†L107-L150】

4. **Notifications & events**
   - Authentication creates a system notification prompting new users to update major.【F:src/main/java/com/swd/exe/teammanagement/service/impl/AuthServiceImpl.java†L72-L90】
   - Join actions notify participants (new leader/member, join request). Notification reads go through `/api/notifications/{id}/read`.【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L68-L135】【F:src/main/java/com/swd/exe/teammanagement/controller/NotificationController.java†L42-L55】
   - WebSocket broadcasts exist but are currently commented out in join/vote services, so real-time updates are disabled by default.【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L68-L104】【F:src/main/java/com/swd/exe/teammanagement/service/impl/VoteServiceImpl.java†L55-L149】

## 5. Additional Notes & Caveats
- **Authentication gap**: Although services assume JWT-based identity, `SecurityConfig` permits all `/api/**` endpoints, meaning unauthenticated requests may reach controllers; service-level lookups will fail with `USER_UNEXISTED` but sensitive data (e.g., `/api/users`) is still exposed to anonymous clients. Consider tightening security rules.【F:src/main/java/com/swd/exe/teammanagement/config/SecurityConfig.java†L30-L45】
- **Comment permissions mismatch**: Controller descriptions mention admin override, yet `CommentServiceImpl` only allows authors to edit/delete and throws otherwise.【F:src/main/java/com/swd/exe/teammanagement/controller/CommentController.java†L31-L47】【F:src/main/java/com/swd/exe/teammanagement/service/impl/CommentServiceImpl.java†L48-L71】
- **Post ownership edge case**: When leaders create `FIND_MEMBER` posts, the `Post` entity lacks a `user` reference; consumers should handle `userResponse` being null. Additionally, `PostServiceImpl.updatePost` allows any leader (even from another group) to edit the post because it only checks leader role, not group ownership—front end should avoid exposing cross-group edit UI until backend enforces it.【F:src/main/java/com/swd/exe/teammanagement/service/impl/PostServiceImpl.java†L55-L159】
- **Vote duplication**: `VoteServiceImpl.voteChoice` does not enforce one vote per member nor validate that the voter belongs to the target group, despite `ErrorCode.DUPLICATE_VOTE` existing. FE should prevent duplicate vote submissions client-side for now.【F:src/main/java/com/swd/exe/teammanagement/service/impl/VoteServiceImpl.java†L64-L118】【F:src/main/java/com/swd/exe/teammanagement/exception/ErrorCode.java†L46-L73】
- **Invite workflow missing**: There is no dedicated invite API/entity—leaders must rely on students initiating `joinGroup` or manually creating votes. Highlight to product/FE if invites are required.
- **Audit of join history**: `Join` records double as history and active membership markers (accepted joins remain active). Ensure UI filters for active membership when showing current roster.
- **Notification channels**: Notification repository stores data, but WebSocket broadcasting is commented out. FE should poll `/api/notifications` or implement WebSocket only after backend re-enables messages.【F:src/main/java/com/swd/exe/teammanagement/service/impl/JoinServiceImpl.java†L68-L104】【F:src/main/java/com/swd/exe/teammanagement/service/impl/VoteServiceImpl.java†L55-L149】
- **Group reset behaviour**: When the last member leaves, `GroupServiceImpl.resetGroup` resets metadata and deactivates related posts/votes/joins—FE should expect group title/description revert to default naming.【F:src/main/java/com/swd/exe/teammanagement/service/impl/GroupServiceImpl.java†L238-L349】
