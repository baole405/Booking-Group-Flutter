# Prompt for Backend Repository Agent

Bạn đang làm việc trong **repo Backend** của dự án Booking Group. Vui lòng thực hiện các bước sau và ghi kết quả vào một file Markdown (ví dụ `BOOKING_GROUP_BACKEND_OVERVIEW.md`) đặt ở thư mục gốc repo:

1. **Khảo sát cấu trúc dự án**
   - Liệt kê nhanh các thư mục chính (controllers, services, repositories, entities, migrations, config...).
   - Chỉ rõ file nào quản lý cấu hình môi trường (env) và setup kết nối database.

2. **Tổng hợp API phục vụ luồng student/leader**
   - Tập trung vào các nghiệp vụ sau:
     - Đăng nhập/ xác thực (đổi Google token → JWT nội bộ).
     - Lấy thông tin user hiện tại, cập nhật hồ sơ, truy vấn user khác.
     - Quản lý group: tạo, cập nhật, đổi trạng thái `FORMING`, xác định leader là member đầu tiên.
     - Xử lý lời mời/ yêu cầu vào nhóm: leader invite student, student gửi join request, vote/approve.
     - Bài post tìm thành viên/ tìm nhóm và comment.
     - Thông báo liên quan (nếu có) khi invite/request được tạo hoặc duyệt.
   - Với mỗi API: ghi rõ HTTP method, route, controller/service xử lý, điều kiện phân quyền, các status code quan trọng, và luồng dữ liệu chính.

3. **Mô tả các model & mối quan hệ liên quan**
   - User, Group, GroupMember, JoinRequest, Invite, Post, Comment, Vote (hoặc tương đương).
   - Các enum/constant quan trọng như trạng thái group (`FORMING`, ...), role (`LEADER`, `MEMBER`), loại post (`FIND_MEMBER`, `FIND_GROUP`).
   - Nêu cách backend đảm bảo rule “khi group status = FORMING thì thành viên đầu tiên là leader”.

4. **Ghi nhận các flow quan trọng**
   - Leader đăng post, student chưa có nhóm comment → leader invite.
   - Student xem group detail và gửi yêu cầu tham gia (bao gồm private/public group nếu có khác biệt).
   - Bất kỳ workflow phê duyệt/ vote trước khi thành viên chính thức tham gia.
   - Các trigger thông báo hoặc event khác (nếu tồn tại).

5. **Các ghi chú bổ sung**
   - Những đoạn code cần chú ý (ví dụ middleware auth, guard, validator).
   - Known issues, TODO comment, hoặc phần logic bất thường mà FE cần lưu ý.
   - Liệt kê mọi endpoint hoặc logic thiếu tài liệu mà bạn không chắc chắn.

6. **Định dạng tài liệu**
   - Sử dụng Markdown, có mục lục, và chia rõ các section theo thứ tự trên.
   - Trong mỗi section, dẫn link/đường dẫn file cụ thể để nhóm FE có thể mở nhanh trong repo backend.

> ⚠️ **Lưu ý quan trọng**: Chỉ tạo/chỉnh sửa file tài liệu; không được thay đổi logic backend. Nếu phát hiện bug hoặc bất thường, hãy note lại trong phần ghi chú.

Sau khi hoàn thành, commit file Markdown vừa tạo trong repo Backend. Cảm ơn!
