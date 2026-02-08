import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:booking_group_flutter/resources/teacher_checkpoint_api.dart';
import 'package:flutter/material.dart';

class SelectTeacherDialog extends StatefulWidget {
  const SelectTeacherDialog({super.key});

  @override
  State<SelectTeacherDialog> createState() => _SelectTeacherDialogState();
}

class _SelectTeacherDialogState extends State<SelectTeacherDialog> {
  final TeacherCheckpointApi _teacherApi = TeacherCheckpointApi();

  List<UserProfile> _teachers = [];
  bool _isLoading = true;
  String? _errorMessage;
  UserProfile? _selectedTeacher;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final teachers = await _teacherApi.getTeacherList();
      setState(() {
        _teachers = teachers;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chọn giảng viên chấm điểm',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(child: _buildContent()),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selectedTeacher != null
                        ? () => Navigator.of(context).pop(_selectedTeacher)
                        : null,
                    child: const Text('Chọn giảng viên'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Không thể tải danh sách giảng viên',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTeachers,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_teachers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Chưa có giảng viên nào',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _teachers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final teacher = _teachers[index];
        final isSelected = _selectedTeacher?.id == teacher.id;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedTeacher = teacher;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.05)
                  : Colors.white,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    teacher.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        teacher.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
