class ProjectMetadata {
  final String id;
  final String name;
  final int width;
  final int height;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<int> pixels;

  ProjectMetadata({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.createdAt,
    required this.modifiedAt,
    required this.pixels,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'width': width,
      'height': height,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'pixels': pixels,
    };
  }

  factory ProjectMetadata.fromJson(Map<String, dynamic> json) {
    return ProjectMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      pixels: (json['pixels'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }

  ProjectMetadata copyWith({
    String? id,
    String? name,
    int? width,
    int? height,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<int>? pixels,
  }) {
    return ProjectMetadata(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      pixels: pixels ?? this.pixels,
    );
  }
}
