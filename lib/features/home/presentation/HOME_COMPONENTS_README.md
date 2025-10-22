# Home Page Components

## 📁 Cấu trúc Components

Trang Home đã được refactor thành các components độc lập, tái sử dụng được:

### 1. **Widgets Components** (`lib/features/home/presentation/widgets/`)

#### `home_header.dart`

- **Mục đích**: Header với logo FPT và menu button
- **Props**:
  - `userEmail`: Email người dùng
  - `onLogout`: Callback khi logout
- **Sử dụng**: Hiển thị logo và menu popup với option logout

#### `home_search_bar.dart`

- **Mục đích**: Search bar để tìm kiếm groups
- **Props**:
  - `onSearch`: Callback khi người dùng nhập text
- **Sử dụng**: TextField với icon search và styling

#### `group_card.dart`

- **Mục đích**: Card hiển thị thông tin 1 group
- **Props**:
  - `group`: Group object
  - `onTap`: Callback khi tap vào card
  - `onJoin`: Callback khi nhấn nút Join
  - `onFavorite`: Callback khi nhấn icon yêu thích
- **Sử dụng**: Card với image placeholder, title, và button Join
- **Tối ưu hóa**:
  - Image height: 90px (giảm từ 100px)
  - Padding: 8px (giảm từ 10px)
  - Button height: 28px với padding 4px
  - Font size: 10px cho button, 13px cho title

#### `group_grid_section.dart`

- **Mục đích**: Section hiển thị grid của groups
- **Props**:
  - `title`: Tiêu đề section
  - `groups`: List các groups
  - `onViewAll`: Callback khi nhấn "View All"
  - `onGroupTap`: Callback khi tap vào group
  - `onGroupJoin`: Callback khi join group
  - `onGroupFavorite`: Callback khi toggle favorite
- **Sử dụng**: GridView với 2 columns, hiển tối đa 4 groups
- **Tối ưu hóa**:
  - `childAspectRatio`: 0.9 để tránh overflow
  - `crossAxisSpacing`: 12px
  - `mainAxisSpacing`: 12px

#### `home_bottom_nav.dart`

- **Mục đích**: Bottom navigation bar
- **Props**:
  - `currentIndex`: Index của tab hiện tại
  - `onTap`: Callback khi tap vào tab
- **Sử dụng**: 4 tabs (Home, Search, Notifications, Profile)

#### `loading_widget.dart`

- **Mục đích**: Loading state indicator
- **Sử dụng**: CircularProgressIndicator ở giữa màn hình

#### `error_state_widget.dart`

- **Mục đích**: Error state với retry button
- **Props**:
  - `error`: Error message
  - `onRetry`: Callback khi nhấn Retry
- **Sử dụng**: Hiển thị icon error, message, và button Retry

---

## 🏠 Home Page (`lib/features/home/presentation/pages/home_page.dart`)

### Cấu trúc mới:

- **State Management**:

  - `_recommendedGroups`: List groups
  - `_isLoading`: Loading state
  - `_error`: Error message
  - `_userEmail`: User email

- **Methods**:

  - `_loadUserData()`: Load user info và groups
  - `_loadGroups()`: Gọi API Backend để lấy groups
  - `_handleLogout()`: Logout logic
  - `_handleRefresh()`: Pull to refresh

- **Build Method**:
  - Sử dụng `CustomScrollView` với `SliverToBoxAdapter`
  - Tích hợp tất cả components
  - Pull-to-refresh enabled

---

## 🎯 Lợi ích của cấu trúc mới:

1. **✅ Clean Code**: Home page chỉ còn ~250 dòng (giảm từ ~500 dòng)
2. **✅ Reusable Components**: Các widgets có thể dùng lại ở pages khác
3. **✅ Easy to Test**: Mỗi component có thể test riêng
4. **✅ Better Performance**: Components nhỏ, render nhanh hơn
5. **✅ Easy to Maintain**: Sửa 1 component không ảnh hưởng phần khác
6. **✅ Fixed Overflow**: Card height được tối ưu, không còn overflow errors

---

## 🔧 Sửa Overflow Error:

### Các thay đổi:

1. **GroupCard**:

   - Image height: 100px → 90px
   - Padding: 10px → 8px
   - Button padding: 6px → 4px
   - Button height: auto → 28px
   - Font sizes: 11px → 10px

2. **GroupGridSection**:
   - `childAspectRatio`: 0.85 → 0.9

### Kết quả:

- ✅ Không còn "RenderFlex overflowed by 32 pixels"
- ✅ Card vừa vặn với nội dung
- ✅ UI gọn gàng, professional

---

## 📝 Sử dụng:

```dart
// Trong home_page.dart
HomeHeader(
  userEmail: _userEmail,
  onLogout: _handleLogout,
)

GroupGridSection(
  title: 'Recommend For You',
  groups: _recommendedGroups,
  onViewAll: () { /* Navigate */ },
  onGroupTap: (group) { /* Show details */ },
  onGroupJoin: (group) { /* Join group */ },
  onGroupFavorite: (group) { /* Toggle favorite */ },
)
```

---

## 🚀 Next Steps:

- [ ] Implement search functionality
- [ ] Add navigation to group details
- [ ] Implement join group logic
- [ ] Add favorite/unfavorite feature
- [ ] Add pagination for groups
