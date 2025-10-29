class Major {
  final int? id;
  final String name;
  final bool active;

  Major({this.id, required this.name, this.active = true});

  factory Major.fromJson(Map<String, dynamic> json) {
    final resolvedName = _readName(json);
    final resolvedId = _readId(json);
    final resolvedActive = _readActive(json);

    return Major(
      id: resolvedId,
      name: resolvedName,
      active: resolvedActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'active': active};
  }
}

int? _readId(Map<String, dynamic> json) {
  final rawId = json['id'] ?? json['majorId'] ?? json['major_id'];
  if (rawId is int) return rawId;
  if (rawId is num) return rawId.toInt();
  if (rawId is String) {
    return int.tryParse(rawId);
  }
  return null;
}

String _readName(Map<String, dynamic> json) {
  final rawName =
      json['name'] ?? json['majorName'] ?? json['major_name'] ?? json['title'];
  if (rawName is String && rawName.trim().isNotEmpty) {
    return rawName.trim();
  }
  return '';
}

bool _readActive(Map<String, dynamic> json) {
  final rawActive = json['active'] ?? json['isActive'] ?? json['status'];
  if (rawActive is bool) return rawActive;
  if (rawActive is num) return rawActive != 0;
  if (rawActive is String) {
    final normalized = rawActive.toLowerCase();
    if (normalized == 'true' || normalized == 'active' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == 'inactive' || normalized == '0') {
      return false;
    }
  }
  return true;
}
