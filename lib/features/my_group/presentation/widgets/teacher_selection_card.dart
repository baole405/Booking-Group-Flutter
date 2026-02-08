import 'package:booking_group_flutter/features/my_group/presentation/dialogs/select_teacher_dialog.dart';
import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:booking_group_flutter/resources/teacher_checkpoint_api.dart';
import 'package:flutter/material.dart';

class TeacherSelectionCard extends StatefulWidget {
  final int groupId;
  final bool isLeader;

  const TeacherSelectionCard({
    super.key,
    required this.groupId,
    required this.isLeader,
  });

  @override
  State<TeacherSelectionCard> createState() => _TeacherSelectionCardState();
}

class _TeacherSelectionCardState extends State<TeacherSelectionCard> {
  final TeacherCheckpointApi _teacherApi = TeacherCheckpointApi();

  Map<String, dynamic>? _teacherRequest;
  bool _isLoading = true;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _loadTeacherRequest();
  }

  Future<void> _loadTeacherRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = await _teacherApi.getMyTeacherRequest(widget.groupId);
      setState(() {
        _teacherRequest = request;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSelectTeacher() async {
    final result = await showDialog<UserProfile>(
      context: context,
      builder: (context) => const SelectTeacherDialog(),
    );

    if (result != null && mounted) {
      setState(() {
        _isRequesting = true;
      });

      try {
        final teacherId = result.id;
        if (teacherId == null) {
          throw Exception('Invalid teacher ID');
        }
        await _teacherApi.requestTeacherCheckpoint(teacherId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã gửi yêu cầu đến GV ${result.fullName}'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadTeacherRequest();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể gửi yêu cầu: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isRequesting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLeader) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Giảng viên chấm điểm',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final status = _teacherRequest?['status'] as String?;
    final teacher = _teacherRequest?['teacher'] as Map<String, dynamic>?;
    final teacherName = teacher?['fullName'] as String? ?? 'Giảng viên';

    if (status == 'ACCEPTED') {
      return _buildStatusCard(
        icon: Icons.check_circle,
        color: Colors.green,
        title: 'Đã chấp nhận',
        message: 'GV $teacherName đã chấp nhận làm giảng viên chấm điểm.',
      );
    }

    if (status == 'PENDING') {
      return _buildStatusCard(
        icon: Icons.hourglass_empty,
        color: Colors.orange,
        title: 'Đang chờ phê duyệt',
        message: 'Đã gửi yêu cầu đến GV $teacherName. Vui lòng chờ xác nhận.',
      );
    }

    if (status == 'REJECTED') {
      return Column(
        children: [
          _buildStatusCard(
            icon: Icons.cancel,
            color: Colors.red,
            title: 'Đã từ chối',
            message: 'Yêu cầu đến GV $teacherName đã bị từ chối.',
          ),
          const SizedBox(height: 12),
          _buildSelectButton(),
        ],
      );
    }

    // No request yet or status is null
    return Column(
      children: [
        Text(
          'Nhóm đã hoàn tất. Vui lòng chọn giảng viên để chấm điểm.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 12),
        _buildSelectButton(),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isRequesting ? null : _handleSelectTeacher,
        icon: _isRequesting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.person_add),
        label: Text(
          _isRequesting
              ? 'Đang gửi yêu cầu...'
              : (_teacherRequest?['status'] == 'REJECTED'
                    ? 'Chọn giảng viên khác'
                    : 'Chọn giảng viên'),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
