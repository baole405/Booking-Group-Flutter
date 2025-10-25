import 'package:booking_group_flutter/features/groups/presentation/widgets/group_card.dart';
import 'package:booking_group_flutter/features/groups/presentation/widgets/groups_filter_section.dart';
import 'package:booking_group_flutter/models/group.dart';
import 'package:booking_group_flutter/resources/group_api.dart';
import 'package:flutter/material.dart';

/// Page displaying all groups with horizontal scroll
class GroupsListPage extends StatefulWidget {
  const GroupsListPage({super.key});

  @override
  State<GroupsListPage> createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  final GroupApi _groupApi = const GroupApi();

  bool _isLoading = true;
  String? _errorMessage;
  List<Group> _groups = [];

  // Filter states
  String? _selectedType;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Loading groups...');
      final groups = await _groupApi.fetchGroups(page: 1, size: 50);
      print('✅ Loaded ${groups.length} groups');

      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading groups: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Group> get _filteredGroups {
    var filtered = _groups;

    if (_selectedType != null) {
      filtered = filtered.where((g) => g.type == _selectedType).toList();
    }

    if (_selectedStatus != null) {
      filtered = filtered.where((g) => g.status == _selectedStatus).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tất cả nhóm',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _groups.isEmpty
          ? _buildEmptyState()
          : _buildGroupsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Lỗi: $_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadGroups,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có nhóm nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList() {
    final filteredGroups = _filteredGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters
        GroupsFilterSection(
          selectedType: _selectedType,
          selectedStatus: _selectedStatus,
          onTypeChanged: (type) {
            setState(() {
              _selectedType = type;
            });
          },
          onStatusChanged: (status) {
            setState(() {
              _selectedStatus = status;
            });
          },
          onClearFilters: () {
            setState(() {
              _selectedType = null;
              _selectedStatus = null;
            });
          },
        ),

        const SizedBox(height: 16),

        // Groups count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Tìm thấy ${filteredGroups.length} nhóm',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Horizontal scrollable list (constrained height so cards don't stretch)
        SizedBox(
          height: 360,
          child: filteredGroups.isEmpty
              ? Center(
                  child: Text(
                    'Không có nhóm phù hợp với bộ lọc',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group = filteredGroups[index];
                    return GroupCard(
                      group: group,
                      onTap: () {
                        // TODO: Navigate to group detail
                        print('Tapped on group: ${group.title}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã chọn: ${group.title}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
