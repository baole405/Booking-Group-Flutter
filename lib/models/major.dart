class Major {
  final int? id;
  final String name;
  final bool active;

  Major({this.id, required this.name, this.active = true});

  factory Major.fromJson(Map<String, dynamic> json) {
    return Major(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'active': active};
  }
}
