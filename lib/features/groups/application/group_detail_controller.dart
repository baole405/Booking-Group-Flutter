import 'package:booking_group_flutter/core/network/api_exception.dart';
import 'package:booking_group_flutter/features/groups/application/group_actions.dart';
import 'package:booking_group_flutter/features/groups/data/group_repository.dart';
import 'package:booking_group_flutter/features/groups/domain/group_models.dart';
import 'package:flutter/material.dart';

class GroupDetailController extends ChangeNotifier {
  GroupDetailController({
    required this.groupId,
    required GroupRepository groupRepository,
    required GroupActions groupActions,
    GroupSummary? initialSummary,
  })  : _groupRepository = groupRepository,
        _groupActions = groupActions,
        summary = initialSummary;

  final int groupId;
  final GroupRepository _groupRepository;
  final GroupActions _groupActions;

  GroupSummary? summary;
  GroupDetail? detail;
  bool isLoading = true;
  bool isJoining = false;
  String? errorMessage;

  bool get hasGroup => _groupActions.hasGroup;
  bool get isMember => summary != null && _groupActions.isInGroup(summary!.id);

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _groupRepository.fetchGroupDetail(groupId);
      summary = result.summary;
      detail = result;
      isLoading = false;
      notifyListeners();
    } on ApiException catch (error) {
      errorMessage = error.message;
      isLoading = false;
      notifyListeners();
    } catch (error) {
      errorMessage = error.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> joinGroup() async {
    if (isJoining) return null;
    isJoining = true;
    notifyListeners();
    try {
      final message = await _groupActions.joinGroup(groupId);
      await load();
      return message;
    } on ApiException catch (error) {
      return error.message;
    } catch (error) {
      return error.toString();
    } finally {
      isJoining = false;
      notifyListeners();
    }
  }
}
