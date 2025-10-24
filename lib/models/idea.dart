/// Idea model
class Idea {
  final int id;
  final String title;
  final String description;
  final Author author;
  final Group group;
  final String status;
  final String createdAt;
  final String updatedAt;

  Idea({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.group,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      author: Author.fromJson(json['author']),
      group: Group.fromJson(json['group']),
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author.toJson(),
      'group': group.toJson(),
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// Author model for Idea
class Author {
  final int id;
  final String fullName;
  final String email;
  final String role;

  Author({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'fullName': fullName, 'email': email, 'role': role};
  }
}

/// Group model for Idea
class Group {
  final int id;
  final String title;

  Group({required this.id, required this.title});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(id: json['id'] as int, title: json['title'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}
