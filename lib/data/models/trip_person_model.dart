class TripPersonModel {
  final String id;
  final String tripId;
  final String name;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripPersonModel({
    required this.id,
    required this.tripId,
    required this.name,
    this.phone = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripPersonModel.fromJson(Map<String, dynamic> json) {
    return TripPersonModel(
      id: json['id'] as String,
      tripId: json['trip_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Person',
      phone: json['phone'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'name': name,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TripPersonModel copyWith({
    String? id,
    String? tripId,
    String? name,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripPersonModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
