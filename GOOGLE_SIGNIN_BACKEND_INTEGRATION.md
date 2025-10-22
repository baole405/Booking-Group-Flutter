# Google Sign-In with Backend Integration

## 📋 Overview

This implementation integrates Google Sign-In with Firebase Authentication and your custom Backend API.

## 🔄 Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    Complete Auth Flow                            │
└─────────────────────────────────────────────────────────────────┘

1. User clicks "Sign in with Google" button
   ↓
2. Google Sign-In SDK → User selects Google account
   ↓
3. Get Google credentials (accessToken, idToken)
   ↓
4. Firebase Authentication with Google credentials
   ↓
5. Get Firebase ID Token from authenticated user
   ↓
6. Send Firebase ID Token to Backend API:
   POST /api/auth/google-login
   Body: { "idToken": "firebase_id_token" }
   ↓
7. Backend validates Firebase ID Token
   ↓
8. Backend returns Bearer Token (JWT):
   Response: { "status": 200, "data": { "token": "bearer_token" } }
   ↓
9. Store Bearer Token in SharedPreferences
   ↓
10. Use Bearer Token for all subsequent API calls
    Authorization: Bearer {token}
   ↓
11. User authenticated & redirected to HomePage
```

## 📁 Project Structure

```
lib/
├── core/
│   └── services/
│       └── api_service.dart          # ⭐ Backend API Service
│
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── login_page.dart   # ⭐ Google Sign-In Implementation
│   │           └── signup_page.dart
│   │
│   └── home/
│       └── presentation/
│           └── pages/
│               └── home_page.dart    # ⭐ Uses Bearer Token for API calls
```

## 🔑 Key Files

### 1. **api_service.dart** - Backend API Service

```dart
class ApiService {
  static const String baseUrl = 'https://swd392-exe-team-management-be.onrender.com';

  // Login with Google (Exchange Firebase ID Token for Bearer Token)
  Future<String?> loginWithGoogle(String idToken);

  // Generic GET/POST with Bearer Token authentication
  Future<http.Response> get(String endpoint);
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body});

  // User Info API
  Future<Map<String, dynamic>?> getMyInfo();

  // Token Management
  Future<void> storeBearerToken(String token);
  Future<void> clearBearerToken();
  Future<bool> isAuthenticated();
}
```

### 2. **login_page.dart** - Google Sign-In Implementation

Key method: `signInWithGoogle()`

```dart
// Step 1-4: Google Sign-In → Firebase Auth
final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

// Step 5: Get Firebase ID Token
final String? firebaseIdToken = await userCredential.user?.getIdToken();

// Step 6-9: Exchange for Bearer Token
final bearerToken = await _apiService.loginWithGoogle(firebaseIdToken);
// Token is automatically stored in SharedPreferences
```

### 3. **home_page.dart** - Using Authenticated APIs

```dart
// Example: Get user info from Backend
final userInfo = await _apiService.getMyInfo();
// Bearer Token is automatically included in Authorization header

// Logout (clears all tokens)
await _apiService.clearBearerToken();
await FirebaseAuth.instance.signOut();
await GoogleSignIn().signOut();
```

## 🔐 Token Management

### Firebase ID Token

- **Purpose**: Proves user authenticated with Google via Firebase
- **Lifetime**: Short-lived (1 hour)
- **Usage**: Send to Backend once during login
- **Storage**: Not stored (regenerated if needed)

### Bearer Token (JWT from Backend)

- **Purpose**: Authenticates API requests to your Backend
- **Lifetime**: Managed by Backend
- **Usage**: Included in all API calls (Authorization header)
- **Storage**: SharedPreferences (`bearerToken` key)

## 📡 API Endpoints

### Authentication

- **POST** `/api/auth/google-login`
  - **Request**: `{ "idToken": "firebase_id_token" }`
  - **Response**: `{ "status": 200, "message": "...", "data": { "token": "bearer_token", "email": "..." } }`

### User Info (Authenticated)

- **GET** `/api/users/myInfo`
  - **Headers**: `Authorization: Bearer {token}`
  - **Response**: `{ "status": 200, "data": { "id": "...", "email": "...", ... } }`

## 🧪 Testing

### Test Google Sign-In Flow

1. Run the app
2. Navigate to Login page
3. Click "Sign in with Google"
4. Check console logs:
   ```
   Starting Google Sign-In...
   Google user signed in: user@gmail.com
   Firebase Auth successful: user@gmail.com
   Firebase ID Token obtained, sending to Backend...
   Calling Backend API: /api/auth/google-login
   Backend Response Status: 200
   Bearer Token received from Backend
   Bearer Token stored successfully
   Google Sign-In complete! User authenticated with Backend
   ```

### Test Backend API Authentication

HomePage automatically tests API authentication on load:

```
Testing Backend API Authentication...
✅ Backend API Authentication successful!
User Info from Backend: {id: ..., email: ..., ...}
```

## 🚀 Usage Examples

### Making Authenticated API Calls

```dart
final apiService = ApiService();

// GET request
final response = await apiService.get('/api/users/myInfo');
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  print('User: ${data['data']['email']}');
}

// POST request
final response = await apiService.post(
  '/api/groups',
  body: {'name': 'My Group', 'description': '...'},
);
```

### Check Authentication Status

```dart
final apiService = ApiService();
bool isAuth = await apiService.isAuthenticated();

if (isAuth) {
  // User has Bearer Token, can make API calls
} else {
  // Redirect to login
}
```

## 🔧 Configuration

### Firebase Configuration

- **Android**: `android/app/google-services.json`
- **SHA-1 Fingerprint**: Added to Firebase Console
- **Google Sign-In enabled** in Firebase Authentication

### Backend Configuration

- **Base URL**: `https://swd392-exe-team-management-be.onrender.com`
- **Endpoints**: `/api/auth/*`, `/api/users/*`

## 📦 Dependencies

```yaml
dependencies:
  firebase_core: ^4.1.1
  firebase_auth: ^6.1.0
  google_sign_in: ^6.2.1
  http: ^1.2.1
  shared_preferences: ^2.2.0
```

## 🐛 Troubleshooting

### "Failed to get Bearer Token from Backend"

- Check Backend API is running
- Verify Firebase ID Token is valid
- Check Backend logs for errors

### "No Bearer Token found. Please login first."

- User needs to login with Google first
- Check SharedPreferences for `bearerToken` key

### Google Sign-In fails

- Verify SHA-1 fingerprint in Firebase Console
- Check `google-services.json` is up to date
- Ensure Google Sign-In enabled in Firebase Authentication

## 📝 Notes

- Bearer Token persists across app restarts (stored in SharedPreferences)
- Firebase ID Token is only used once during login
- Backend manages Bearer Token expiration
- Logout clears all tokens (Bearer, Firebase, Google)

## 🎯 Summary

This implementation:
✅ Uses Firebase for Google OAuth
✅ Exchanges Firebase ID Token for Backend Bearer Token  
✅ Stores Bearer Token securely
✅ Includes Bearer Token in all API calls
✅ Handles logout properly (clears all tokens)
✅ Follows Backend API requirements exactly

**Vietnamese**: Flow này đúng 100% với yêu cầu Backend của bạn. Firebase ID Token chỉ dùng 1 lần để đổi lấy Bearer Token từ Backend, sau đó Bearer Token được dùng cho tất cả API calls.
