import 'package:booking_group_flutter/core/network/api_exception.dart';
import 'package:booking_group_flutter/features/groups/application/group_actions.dart';
import 'package:booking_group_flutter/features/groups/data/group_repository.dart';
import 'package:booking_group_flutter/features/groups/domain/group_models.dart';
import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required GroupRepository groupRepository,
    required GroupActions groupActions,
  })  : _groupRepository = groupRepository,
        _groupActions = groupActions;

  final GroupRepository _groupRepository;
  final GroupActions _groupActions;

  bool isLoading = true;
  String? errorMessage;
  List<GroupSummary> groups = const <GroupSummary>[];

  final Set<int> _joiningGroupIds = <int>{};

  bool isJoining(int groupId) => _joiningGroupIds.contains(groupId);

  bool get hasGroup => _groupActions.hasGroup;

  Future<void> loadGroups() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      groups = await _groupRepository.fetchAvailableGroups();
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

  Future<String?> joinGroup(GroupSummary group) async {
    if (_joiningGroupIds.contains(group.id)) return null;
    _joiningGroupIds.add(group.id);
    notifyListeners();
    try {
      final message = await _groupActions.joinGroup(group.id);
      return message;
    } on ApiException catch (error) {
      return error.message;
    } catch (error) {
      return error.toString();
    } finally {
      _joiningGroupIds.remove(group.id);
      notifyListeners();
    }
  }

  bool isMemberOf(GroupSummary group) => _groupActions.isInGroup(group.id);
}
