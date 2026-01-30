import 'location_model.dart';

/// Trip model representing a travel itinerary
class TripModel {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final List<LocationModel> locations;
  final DateTime startDate;
  final DateTime? endDate;
  final TripStatus status;
  final bool isPublic;
  final List<String> companionIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TripModel({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.locations = const [],
    required this.startDate,
    this.endDate,
    this.status = TripStatus.planned,
    this.isPublic = true,
    this.companionIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripModel.fromMap(Map<String, dynamic> map, String id) {
    return TripModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      locations: (map['locations'] as List<dynamic>?)
              ?.map((l) => LocationModel.fromMap(l as Map<String, dynamic>))
              .toList() ??
          [],
      startDate: map['startDate']?.toDate() ?? DateTime.now(),
      endDate: map['endDate']?.toDate(),
      status: TripStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TripStatus.planned,
      ),
      isPublic: map['isPublic'] ?? true,
      companionIds: List<String>.from(map['companionIds'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'locations': locations.map((l) => l.toMap()).toList(),
      'startDate': startDate,
      'endDate': endDate,
      'status': status.name,
      'isPublic': isPublic,
      'companionIds': companionIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TripModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    List<LocationModel>? locations,
    DateTime? startDate,
    DateTime? endDate,
    TripStatus? status,
    bool? isPublic,
    List<String>? companionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      locations: locations ?? this.locations,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      companionIds: companionIds ?? this.companionIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Trip status enum
enum TripStatus {
  planned,
  active,
  completed,
  cancelled,
}
