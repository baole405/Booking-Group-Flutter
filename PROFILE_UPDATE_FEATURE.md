# Profile Update Feature - Major Selection

## Tổng quan

Tính năng cho phép người dùng cập nhật chuyên ngành (major) trong profile của họ.

## Backend API

- **GET /api/majors**: Lấy danh sách tất cả chuyên ngành
- **PUT /api/users/myInfo**: Cập nhật thông tin user (majorId, cvUrl, avatarUrl)

## Cấu trúc Files

### 1. API Constants (Updated)

**File**: `lib/core/constants/api_constants.dart`

Thêm 2 endpoints mới:

```dart
static String get updateMyInfoUrl => '$baseApiUrl$myInfo';
static String get majorsUrl => '$baseApiUrl$majors';
```

### 2. Major API Service (New)

**File**: `lib/resources/major_api.dart`

Service để lấy danh sách chuyên ngành:

```dart
class MajorApi {
  Future<List<Major>> getAllMajors() async
}
```

**Features**:

- Tự động lấy bearer token từ SharedPreferences
- Parse response thành List<Major>
- Error handling với try-catch

### 3. Profile Update API Service (New)

**File**: `lib/resources/profile_update_api.dart`

Service để cập nhật thông tin profile:

```dart
class ProfileUpdateApi {
  Future<bool> updateProfile({String? cvUrl, String? avatarUrl, int? majorId})
  Future<bool> updateMajor(int majorId)
}
```

**Features**:

- `updateProfile()`: Cập nhật nhiều field (nullable fields)
- `updateMajor()`: Convenience method chỉ cập nhật major
- Tự động lấy bearer token
- Build request body dynamic (chỉ include non-null fields)
- Handle status codes 200 và 1073741824

### 4. Major Selector Bottom Sheet (New)

**File**: `lib/features/profile/presentation/widgets/major_selector_bottom_sheet.dart`

Bottom sheet UI để chọn chuyên ngành:

**Components**:

- **Header**:
  - Close button (trái)
  - Title "Chọn chuyên ngành" (giữa)
- **Content Area**:
  - Loading state: CircularProgressIndicator
  - Error state: Error icon + message + retry button
  - Empty state: Info icon + message
  - Major list: ListView.builder với các major items
- **Major Item** (ListTile):
  - Icon: Circle avatar (blue nếu selected, grey nếu không)
  - Title: Major name (bold nếu selected)
  - Trailing: Check icon nếu selected
- **Bottom Button**:
  - "Xác nhận" button
  - Disabled nếu chưa select major
  - Enabled và primary color nếu đã select

**Helper Function**:

```dart
Future<Major?> showMajorSelector(
  BuildContext context, {
  Major? currentMajor,
})
```

**States Management**:

- `_isLoading`: Loading state
- `_majors`: List of available majors
- `_selectedMajor`: Currently selected major
- `_errorMessage`: Error message nếu có

### 5. Profile Page (Updated)

**File**: `lib/features/profile/presentation/pages/profile_page.dart`

**Changes**:

1. **Imports**: Thêm ProfileUpdateApi và MajorSelectorBottomSheet
2. **Major Display**:
   - Thay `_ProfileInfoRow` bằng `_ProfileInfoRowWithEdit`
   - Hiển thị "Chưa cập nhật" nếu user chưa có major
3. **Edit Handler**: Thêm `_handleEditMajor()` method

**\_handleEditMajor() Flow**:

```
1. Show major selector bottom sheet
2. If user selects a major:
   a. Validate major ID không null
   b. Show loading snackbar
   c. Call ProfileUpdateApi.updateMajor()
   d. If success:
      - Reload profile (_loadUserProfile)
      - Show success message
   e. If fail:
      - Show error message
3. If user cancels: Do nothing
```

**New Widget**: `_ProfileInfoRowWithEdit`

- Giống `_ProfileInfoRow` nhưng có thêm edit button
- Edit button ở góc phải label
- OnPressed trigger edit handler

## User Flow

1. User mở Profile Page
2. User nhìn thấy field "Chuyên ngành" với giá trị hiện tại (hoặc "Chưa cập nhật")
3. User click nút "Chỉnh sửa" bên cạnh label
4. Bottom sheet xuất hiện với danh sách chuyên ngành
5. User chọn một chuyên ngành từ list (item highlight blue)
6. User click "Xác nhận"
7. Loading snackbar xuất hiện
8. API call đến Backend
9. Nếu thành công:
   - Profile reload tự động
   - Major mới hiển thị
   - Success message xuất hiện
10. Nếu thất bại:
    - Error message xuất hiện
    - User có thể thử lại

## Error Handling

### Major API

- Không có token → Exception
- Network error → rethrow
- Empty response → return empty list

### Profile Update API

- Không có token → Exception
- Major ID null → Validation message
- API error → Error snackbar

### Major Selector

- Loading state → Spinner
- Error loading majors → Error UI với retry button
- Empty majors list → Empty state message
- Network issues → Try-catch với error display

## Testing Checklist

- [ ] Load danh sách majors thành công
- [ ] Hiển thị current major nếu có
- [ ] Select major mới từ list
- [ ] Confirm update major
- [ ] Reload profile sau khi update
- [ ] Handle errors gracefully
- [ ] Loading states hiển thị đúng
- [ ] Cancel bottom sheet không trigger update
- [ ] Validate major ID trước khi call API
- [ ] Token authentication hoạt động

## Future Enhancements

1. **Avatar Update**: Thêm edit button cho avatar
   - Image picker integration
   - Upload image to server
   - Update avatarUrl
2. **CV Update**: Thêm edit button cho CV

   - File picker integration
   - Upload PDF to server
   - Update cvUrl

3. **Full Name Update**: Cho phép edit tên

   - Text input dialog
   - Validate input
   - Update fullName

4. **Offline Support**:
   - Cache majors list
   - Queue updates khi offline
   - Sync khi online lại

## Dependencies

- `http`: API calls
- `shared_preferences`: Token storage
- `flutter/material.dart`: UI components
- Custom models: `Major`, `UserProfile`
