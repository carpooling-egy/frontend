import 'package:json_annotation/json_annotation.dart';

part 'recent_trip.g.dart';

@JsonSerializable(explicitToJson: true)
class RecentTrip {
  final String id;
  final String type; // 'ride_offer' or 'ride_request'
  final String userRole; // 'driver' or 'rider'
  final String source;
  final String destination;
  final DateTime departureTime;
  final bool matched;
  final int? remainingCapacity;
  final List<MatchedRider>? matchedRiders;
  final DriverInfo? driver;
  final DateTime? pickupTime;

  RecentTrip({
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
    this.pickupTime,
  });

  factory RecentTrip.fromJson(Map<String, dynamic> json) => _$RecentTripFromJson(json);
  Map<String, dynamic> toJson() => _$RecentTripToJson(this);
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

  DriverInfo({
    required this.id,
    required this.name,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) => _$DriverInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DriverInfoToJson(this);
} 