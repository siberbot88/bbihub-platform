class WorkshopDocument {
  final String id;
  final String workshopUuid;
  final String nib;
  final String npwp;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkshopDocument({
    required this.id,
    required this.workshopUuid,
    required this.nib,
    required this.npwp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkshopDocument.fromJson(Map<String, dynamic> json) {
    return WorkshopDocument(
      id: json['id'],
      workshopUuid: json['workshop_uuid'],
      nib: json['nib'],
      npwp: json['npwp'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
