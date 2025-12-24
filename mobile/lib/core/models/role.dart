class Role {
  final String name;

  Role({required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
        name: json['name'] as String,
    );
  }
}