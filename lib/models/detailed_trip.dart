import 'package:json_annotation/json_annotation.dart';

part 'detailed_trip.g.dart';

@JsonSerializable(explicitToJson: true)
class DetailedTrip {
  final String id;
  final String type;
  final String userRole;
  final String source;
  final String destination;
  final DateTime departureTime;
  final bool matched;
  final int? remainingCapacity;
  final List<MatchedRider>? matchedRiders;
  final DriverInfo? driver;
  final List<LatLngPoint>? path;
  final String? notes;
  final VehicleInfo? vehicle;
  final DateTime? pickupTime;

  DetailedTrip({
    required this.id,
    required this.type,
    required this.userRole,
    required this.source,
    required this.destination,
    required this.departureTime,
    required this.matched,
    this.remainingCapacity,
    this.matchedRiders,
    this.driver,
    this.path,
    this.notes,
    this.vehicle,
    this.pickupTime,
  });

  factory DetailedTrip.fromJson(Map<String, dynamic> json) => _$DetailedTripFromJson(json);
  Map<String, dynamic> toJson() => _$DetailedTripToJson(this);
}

@JsonSerializable()
class MatchedRider {
  final String id;
  final String name;
  final DateTime? pickupTime;

  MatchedRider({
    required this.id,
    required this.name,
    this.pickupTime,
  });

  factory MatchedRider.fromJson(Map<String, dynamic> json) => _$MatchedRiderFromJson(json);
  Map<String, dynamic> toJson() => _$MatchedRiderToJson(this);
}

@JsonSerializable()
class DriverInfo {
  final String id;
  final String name;
  final String? phone;

  DriverInfo({
    required this.id,
    required this.name,
    this.phone,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) => _$DriverInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DriverInfoToJson(this);
}

@JsonSerializable()
class VehicleInfo {
  final String make;
  final String model;
  final String color;
  final String plate;

  VehicleInfo({
    required this.make,
    required this.model,
    required this.color,
    required this.plate,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) => _$VehicleInfoFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleInfoToJson(this);
}

@JsonSerializable()
class LatLngPoint {
  final double lat;
  final double lng;

  LatLngPoint({
    required this.lat,
    required this.lng,
  });

  factory LatLngPoint.fromJson(Map<String, dynamic> json) => _$LatLngPointFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngPointToJson(this);
} 