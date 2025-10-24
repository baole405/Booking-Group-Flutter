/// My Group model - for the current user's group
class MyGroup {
  final int id;
  final String title;
  final String description;
  final Semester semester;
  final String type;
  final String status;
  final String createdAt;
  final bool active;

  MyGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.semester,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.active,
  });

  factory MyGroup.fromJson(Map<String, dynamic> json) {
    return MyGroup(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      semester: Semester.fromJson(json['semester']),
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      active: json['active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'semester': semester.toJson(),
      'type': type,
      'status': status,
      'createdAt': createdAt,
      'active': active,
    };
  }
}

/// Semester model
class Semester {
  final int id;
  final String name;
  final bool active;

  Semester({required this.id, required this.name, required this.active});

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'] as int,
      name: json['name'] as String,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'active': active};
  }
}
