import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:booking_group_flutter/models/major.dart';
import 'package:booking_group_flutter/models/group.dart';
import 'package:booking_group_flutter/features/ai_chat/models/ai_chat_message.dart';

class MockDataService {
  static const bool useMock = true;

  // Mock User
  static final UserProfile mockUser = UserProfile(
    id: 1,
    studentCode: 'SE123456',
    fullName: 'Nguyen Van A (Mock)',
    email: 'anv@fpt.edu.vn',
    role: 'STUDENT',
    major: Major(id: 1, name: 'Software Engineering'),
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
  );

  static final String mockToken = 'mock-jwt-token-123456';

  // Mock Groups
  static final List<Group> mockGroups = [
    Group(
      id: 101,
      title: 'Capstone Project: AI Education',
      description: 'Looking for 2 Backend devs proficient in Python/FastAPI',
      type: 'CAPSTONE',
      status: 'RECRUITING',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      semester: GroupSemester(id: 1, name: 'Spring 2024', active: true),
    ),
    Group(
      id: 102,
      title: 'Mobile App for Bus Tracking',
      description: 'Need UI/UX designer and Flutter dev',
      type: 'COURSE_PROJECT',
      status: 'RECRUITING',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      semester: GroupSemester(id: 1, name: 'Spring 2024', active: true),
    ),
  ];

  // Mock AI Chat
  static final List<AiChatMessage> mockAiHistory = [
    AiChatMessage(
      id: 'msg-1',
      role: AiChatRole.user,
      content: 'Chào bạn, mình muốn tìm nhóm làm đồ án.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    AiChatMessage(
      id: 'msg-2',
      role: AiChatRole.assistant,
      content: 'Chào bạn! Mình có thể giúp gì cho bạn? Bạn đang tìm nhóm chuyên về mảng nào (AI, Web, Mobile...)?',
      createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
  ];
}
