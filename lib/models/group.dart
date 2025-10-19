class Group {
  const Group({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.semester,
  });

  final int id;
  final String title;
  final String? description;
  final String type;
  final String status;
  final DateTime? createdAt;
  final GroupSemester? semester;

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled group',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'UNKNOWN',
      status: json['status'] as String? ?? 'UNKNOWN',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      semester: json['semester'] == null
          ? null
          : GroupSemester.fromJson(
              Map<String, dynamic>.from(json['semester'] as Map),
            ),
    );
  }
}

class GroupSemester {
  const GroupSemester({
    required this.id,
    required this.name,
    required this.active,
  });

  final int id;
  final String name;
  final bool active;

  factory GroupSemester.fromJson(Map<String, dynamic> json) {
    return GroupSemester(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? false,
    );
  }
}
