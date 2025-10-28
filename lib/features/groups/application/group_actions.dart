import 'package:booking_group_flutter/features/auth/application/session_controller.dart';
import 'package:booking_group_flutter/features/groups/data/group_repository.dart';

class GroupActions {
  GroupActions({
    required GroupRepository groupRepository,
    required SessionController sessionController,
  })  : _groupRepository = groupRepository,
        _sessionController = sessionController;

  final GroupRepository _groupRepository;
  final SessionController _sessionController;

  bool get hasGroup => _sessionController.hasGroup;

  bool isInGroup(int groupId) =>
      _sessionController.currentGroupId != null &&
      _sessionController.currentGroupId == groupId;

  Future<String> joinGroup(int groupId) async {
    final message = await _groupRepository.joinGroup(groupId);
    await _sessionController.reloadProfile();
    return message;
  }
}
