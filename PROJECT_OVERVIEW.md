# 📱 Booking Group Flutter - Mobile Application Documentation

## 🎯 Project Overview

**Booking Group Flutter** is a Flutter-based mobile application for managing student groups in an academic environment. The app allows students to create, join, and manage groups for semester projects, with features for idea management, forum discussions, and join request handling.

---

## ⚠️ IMPORTANT NOTICE FOR AI ASSISTANTS

**🚫 DO NOT MODIFY BACKEND CODE OR API ENDPOINTS**

This documentation is for **MOBILE DEVELOPMENT ONLY**. You are working with:
- ✅ Flutter/Dart code in the mobile app
- ✅ UI/UX components and widgets
- ✅ State management and navigation
- ✅ API integration (client-side only)

**You are NOT allowed to:**
- ❌ Modify backend API endpoints
- ❌ Change API response structures
- ❌ Suggest backend changes
- ❌ Modify server-side logic

**You CAN:**
- ✅ View API documentation to understand responses
- ✅ Handle API responses safely with null checks
- ✅ Add error handling for API calls
- ✅ Improve mobile UI/UX

---

## 🏗️ Architecture

### Tech Stack
- **Framework:** Flutter 3.35.4
- **Language:** Dart
- **Authentication:** Firebase Auth (Email-based)
- **State Management:** StatefulWidget with setState
- **HTTP Client:** http package
- **Local Storage:** SharedPreferences (Bearer token)

### Backend API
- **Base URL:** `https://swd392-exe-team-management-be.onrender.com`
- **Authentication:** Bearer Token (stored in SharedPreferences)
- **Response Format:** JSON with structure `{status: number, message: string, data: object}`

---

## 📂 Project Structure

```
lib/
├── core/
│   └── constants/
│       └── api_constants.dart          # API URLs and headers
├── models/
│   ├── my_group.dart                   # User's group model
│   ├── group.dart                      # Group list model
│   ├── group_member.dart               # Member model
│   ├── idea.dart                       # Idea model
│   ├── post.dart                       # Forum post model
│   ├── user_profile.dart               # User profile model
│   └── join_request.dart               # Join request model
├── resources/
│   ├── my_group_api.dart               # My Group API service
│   ├── groups_api.dart                 # Groups API service
│   ├── join_request_api.dart           # Join Request API service
│   └── posts_api.dart                  # Posts API service
└── features/
    ├── auth/                           # Authentication pages
    │   ├── login_page.dart
    │   └── signup_page.dart
    ├── home/                           # Home page
    │   ├── presentation/pages/home_page.dart
    │   └── presentation/widgets/
    │       ├── groups_section_card.dart
    │       ├── your_group_section_card.dart
    │       └── your_request_section_card.dart
    ├── my_group/                       # User's Group features
    │   ├── presentation/pages/my_group_detail_page.dart
    │   └── presentation/widgets/
    │       ├── group_info_card.dart
    │       ├── leader_section.dart
    │       ├── members_section.dart
    │       └── ideas_section.dart
    ├── groups/                         # All Groups features
    │   ├── presentation/pages/
    │   │   ├── groups_list_page.dart
    │   │   └── group_detail_page.dart
    │   └── presentation/widgets/
    │       ├── group_card.dart
    │       ├── group_detail_info_card.dart
    │       ├── group_detail_leader_section.dart
    │       └── group_detail_members_section.dart
    ├── ideas/                          # Group Ideas features
    │   ├── presentation/pages/
    │   │   ├── group_ideas_page.dart
    │   │   └── all_ideas_page.dart
    │   └── presentation/widgets/idea_card.dart
    ├── forum/                          # Forum features
    │   ├── presentation/pages/forum_page.dart
    │   └── presentation/widgets/post_card.dart
    └── requests/                       # Join Requests features
        ├── presentation/pages/your_requests_page.dart
        └── presentation/widgets/request_card.dart
```

---

## 🔐 Authentication Flow

### Login Process
1. User enters email and password
2. Firebase Auth validates credentials
3. On success, retrieve Firebase ID token
4. Call backend `/api/auth/login` with Firebase token
5. Backend returns Bearer token
6. Store Bearer token in SharedPreferences
7. Navigate to HomePage

### Signup Process
1. User enters email, password, full name, student code, major
2. Firebase Auth creates account
3. Call backend `/api/auth/register` with user data
4. Backend creates user profile
5. Auto-login and navigate to HomePage

---

## 🎭 User Roles & Permissions

### Group Leader
- ✅ Create new ideas for the group
- ✅ Edit existing ideas
- ✅ Delete ideas
- ✅ Manage group members (if features exist)

### Group Member
- ✅ View group information
- ✅ View group ideas (read-only)
- ✅ View other members
- ❌ Cannot edit or delete ideas

### Non-Member
- ✅ Browse all public groups
- ✅ Join FORMING groups (become leader)
- ✅ Request to join ACTIVE groups
- ❌ Cannot view group ideas

---

## 📊 Group Status Lifecycle

### Status Flow
```
FORMING → ACTIVE → COMPLETED / DISBANDED
```

### Status Descriptions

1. **FORMING** (Đang tạo)
   - Group has no leader yet
   - First person to join becomes the leader
   - Group automatically changes to ACTIVE when someone joins
   - **Join Button:** "Tham gia nhóm" → Shows confirmation dialog

2. **ACTIVE** (Hoạt động)
   - Group has a leader
   - Members can be added
   - **Join Button:** "Tham gia nhóm" → Sends join request
   - Leader can manage ideas

3. **COMPLETED** (Hoàn thành)
   - Group has finished its project
   - Read-only mode

4. **DISBANDED** (Giải tán)
   - Group has been disbanded
   - Read-only mode

---

## 🎯 Core Features & User Flows

### 1. Home Page (`/features/home/`)

**What User Sees:**
- **Groups Section Card:** Browse all available groups
- **Your Group Section Card:** Quick access to user's current group (if any)
- **Your Request Section Card:** Manage join requests with badge count

**User Actions:**
- Tap "Groups" → Navigate to Groups List
- Tap "Your Group" → Navigate to My Group Detail (if in a group)
- Tap "Your Request" → Navigate to Your Requests Page

---

### 2. Groups List (`/features/groups/`)

**Page:** `groups_list_page.dart`

**What User Sees:**
- List of all groups from API
- Each card shows: Title, Status badge, Description, Semester, Type, Created date, Member count
- Search functionality (if implemented)

**User Actions:**
- Tap on any group card → Navigate to Group Detail Page

---

### 3. Group Detail Page (`/features/groups/`)

**Page:** `group_detail_page.dart`

**Components:**
- `GroupDetailInfoCard` - Group information
- `GroupDetailLeaderSection` - Leader info with join button (for FORMING groups)
- `GroupDetailMembersSection` - List of members

**User Flow for FORMING Groups:**
1. User views group with status "FORMING"
2. Sees "Nhóm chưa có trưởng nhóm" in leader section
3. Clicks "Tham gia nhóm" button
4. Confirmation dialog: "Xác nhận làm trưởng nhóm"
5. If confirmed:
   - Call `POST /api/joins/{groupId}`
   - Backend makes user the leader
   - Backend changes status FORMING → ACTIVE
   - App shows success message
   - **Smart Retry Logic:** App waits and retries up to 5 times to ensure backend is ready
   - Navigate to My Group Detail Page

**User Flow for ACTIVE Groups:**
1. User views group with status "ACTIVE"
2. Sees current leader information
3. Clicks "Tham gia nhóm" button (FloatingActionButton)
4. Sends join request to backend
5. Request appears in "Your Requests"

---

### 4. My Group Detail (`/features/my_group/`)

**Page:** `my_group_detail_page.dart`

**What User Sees:**
- `GroupInfoCard` - Group details with status badge
- `LeaderSection` - Leader information with purple "Leader" badge
- `MembersSection` - All group members (leader has badge)
- `IdeasSection` - Group ideas list

**Leader-Specific Features:**
- ➕ "Thêm ý tưởng" button (floating action)
- ✏️ Edit button on each idea card
- 🗑️ Delete button on each idea card

**Member View:**
- 👀 Read-only view of ideas
- No edit/delete buttons

**Empty States:**
- "Bạn chưa tham gia nhóm nào" → Shows button to browse groups
- "Chưa có ý tưởng nào" → Leader can add ideas

---

### 5. Group Ideas (`/features/ideas/`)

**Page:** `group_ideas_page.dart`

**Purpose:** Manage ideas for user's group

**Features:**
- View all ideas in user's group
- **Leader only:** 
  - Create new idea dialog
  - Edit idea dialog
  - Delete idea with confirmation

**Idea Card Structure:**
- Title
- Description
- Tags (if any)
- Created date
- Action buttons (for leader)

---

### 6. All Ideas (`/features/ideas/`)

**Page:** `all_ideas_page.dart`

**Purpose:** Browse all ideas from all groups (Admin/Teacher feature)

**What User Sees:**
- Ideas from all groups
- Group name for each idea
- Read-only view

---

### 7. Forum (`/features/forum/`)

**Page:** `forum_page.dart`

**Purpose:** Community discussion board

**What User Sees:**
- List of all forum posts
- Post cards with: Title, Content, Author, Date
- Public discussion space

**Current Status:** Read-only view (posting not implemented yet)

---

### 8. Your Requests (`/features/requests/`)

**Page:** `your_requests_page.dart`

**Purpose:** Manage user's join requests

**What User Sees:**
- List of pending join requests
- Request cards showing: Group name, Request date, Status
- Badge count on home page card

**User Actions:**
- View request details
- Cancel request (DELETE request)

**Empty State:**
- "Chưa có yêu cầu nào" → Shows button to browse groups

---

## 🔌 API Integration

### Key API Endpoints (READ-ONLY REFERENCE)

#### Authentication
```
POST /api/auth/register
POST /api/auth/login
```

#### Groups
```
GET  /api/groups                    # List all groups
GET  /api/groups/{id}               # Get group by ID
GET  /api/groups/my-group           # Get user's group
GET  /api/groups/{id}/members       # Get group members
GET  /api/groups/{id}/leader        # Get group leader (404 if no leader)
```

#### Ideas
```
GET    /api/groups/{id}/ideas       # Get group ideas
POST   /api/ideas                   # Create idea (Leader only)
PUT    /api/ideas/{id}              # Update idea (Leader only)
DELETE /api/ideas/{id}              # Delete idea (Leader only)
GET    /api/ideas                   # Get all ideas (Admin/Teacher)
```

#### Join Requests
```
POST   /api/joins/{groupId}         # Join group or send request
GET    /api/joins/my-requests       # Get user's requests
DELETE /api/joins/{joinId}          # Cancel request
GET    /api/joins/{groupId}/pending # Get pending requests for group
```

#### Forum
```
GET /api/posts                      # Get all forum posts
```

---

## 🎨 UI/UX Patterns

### Color Scheme
- **Primary:** Purple (`Color(0xFF8B5CF6)`)
- **Success:** Green
- **Warning:** Orange
- **Error:** Red
- **Info:** Blue

### Status Colors
- **FORMING:** Orange
- **ACTIVE:** Green
- **COMPLETED:** Blue
- **DISBANDED:** Red

### Type Colors
- **PUBLIC:** Blue
- **PRIVATE:** Purple

### Common Widgets
- **Card with gradient background** - Used for section cards on home
- **Status badges** - Rounded containers with colored background
- **Leader badge** - Purple container with white "Leader" text
- **Empty state screens** - Centered message with action button

---

## 🔄 State Management

### Pattern Used
- StatefulWidget with setState
- Local state management per page
- API calls in initState or button handlers

### Loading States
```dart
bool _isLoading = true;
String? _error;

setState(() {
  _isLoading = true;
  _error = null;
});

try {
  // API call
  setState(() {
    // Update data
  });
} catch (e) {
  setState(() {
    _error = e.toString();
  });
} finally {
  setState(() {
    _isLoading = false;
  });
}
```

---

## 🛡️ Error Handling

### API Error Patterns

1. **Null Safety:**
   ```dart
   final title = (json['title'] as String?) ?? '';
   final semester = json['semester'] != null 
       ? Semester.fromJson(json['semester']) 
       : null;
   ```

2. **Type Safety:**
   ```dart
   String getStringValue(dynamic value, [String defaultValue = '']) {
     if (value == null) return defaultValue;
     if (value is String) return value;
     if (value is Map) return value['name']?.toString() ?? defaultValue;
     return value.toString();
   }
   ```

3. **Retry Logic:**
   ```dart
   Future<void> _loadData({int retryCount = 0}) async {
     try {
       // API call
     } catch (e) {
       if (e.toString().contains('500') && retryCount < 2) {
         await Future.delayed(const Duration(seconds: 2));
         return _loadData(retryCount: retryCount + 1);
       }
       // Handle error
     }
   }
   ```

---

## 🐛 Common Issues & Solutions

### Issue 1: Type Cast Error
**Problem:** `type '_Map<String, dynamic>' is not a subtype of type 'String'`

**Solution:** Use safe type checking helper functions
```dart
String getStringValue(dynamic value, [String defaultValue = '']) {
  if (value == null) return defaultValue;
  if (value is String) return value;
  if (value is Map) return value['name']?.toString() ?? defaultValue;
  return value.toString();
}
```

### Issue 2: Backend 500 Error After Join
**Problem:** Backend returns 500 when calling my-group API immediately after joining

**Solution:** Smart retry logic with delays
```dart
// Wait and retry up to 5 times
bool groupReady = false;
int retries = 0;
const maxRetries = 5;

while (!groupReady && retries < maxRetries) {
  await Future.delayed(Duration(seconds: retries == 0 ? 2 : 3));
  try {
    final myGroup = await _myGroupApi.getMyGroup();
    if (myGroup != null && myGroup.id == widget.groupId) {
      groupReady = true;
    }
  } catch (e) {
    retries++;
  }
}
```

### Issue 3: Nullable Fields
**Problem:** Backend may return null for optional fields

**Solution:** Always use nullable types and default values
```dart
class MyGroup {
  final Semester? semester;  // Nullable
  
  factory MyGroup.fromJson(Map<String, dynamic> json) {
    return MyGroup(
      semester: json['semester'] != null 
          ? Semester.fromJson(json['semester']) 
          : null,
    );
  }
}
```

---

## 📝 Code Guidelines

### 1. Always Handle Nulls
```dart
// ✅ Good
final name = groupDetail['name'] as String? ?? 'N/A';

// ❌ Bad
final name = groupDetail['name'] as String;  // May crash
```

### 2. Use Mounted Check
```dart
// ✅ Good
if (mounted) {
  setState(() { /* ... */ });
}

// ❌ Bad
setState(() { /* ... */ });  // May crash if widget disposed
```

### 3. Add Loading & Error States
```dart
// ✅ Always include
if (_isLoading) {
  return Center(child: CircularProgressIndicator());
}

if (_error != null) {
  return Center(child: Text('Error: $_error'));
}
```

### 4. Use Const Constructors
```dart
// ✅ Good
const SizedBox(height: 16)

// ❌ Bad
SizedBox(height: 16)
```

---

## 🚀 Development Workflow

### Adding a New Feature

1. **Create Model** (if needed)
   - Add to `lib/models/`
   - Include `fromJson` and `toJson` methods
   - Handle nullable fields

2. **Create API Service** (if needed)
   - Add to `lib/resources/`
   - Use bearer token from SharedPreferences
   - Add error handling

3. **Create Page**
   - Add to appropriate feature folder
   - Include loading/error states
   - Use mounted checks

4. **Create Widgets**
   - Add to feature's widgets folder
   - Make reusable components
   - Use const constructors

5. **Add Navigation**
   - Update from calling page
   - Use MaterialPageRoute
   - Consider pushReplacement for auth flows

---

## 🔍 Debugging Tips

### View API Responses
```dart
print('📊 Response: ${response.statusCode}');
print('📦 Data: ${jsonResponse['data']}');
```

### Check Data Types
```dart
print('Type: ${value.runtimeType}');
```

### Track Navigation
```dart
print('🔀 Navigating to: MyGroupDetailPage');
```

---

## 📚 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^4.1.1
  firebase_auth: ^6.1.0
  http: ^1.1.0
  shared_preferences: ^2.2.2
  intl: ^0.18.1
```

---

## 🎓 Learning Resources

### Flutter Docs
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)
- [State Management](https://docs.flutter.dev/data-and-backend/state-mgmt)
- [Navigation](https://docs.flutter.dev/ui/navigation)

### Best Practices
- Always use `const` for immutable widgets
- Handle all error cases
- Add loading indicators for async operations
- Use meaningful variable names
- Comment complex logic

---

## 📞 Support

For mobile development questions:
- Check this documentation first
- Review existing similar features
- Look at API service implementations
- Check model definitions for data structure

**Remember:** You're working with mobile code only. Backend is read-only for reference!

---

**Last Updated:** October 27, 2025  
**Flutter Version:** 3.35.4  
**Project Type:** Educational Group Management System
