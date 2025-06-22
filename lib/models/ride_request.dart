import 'package:json_annotation/json_annotation.dart';
import 'package:frontend/utils/date_time_utils.dart';

part 'ride_request.g.dart';

@JsonSerializable()
class RideRequest {
  final String? id;
  final String? userId;
  final double sourceLatitude;
  final double sourceLongitude;
  final String sourceAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationAddress;
  final DateTime earliestDepartureTime;
  final DateTime latestArrivalTime;
  final int maxWalkingTimeMinutes;
  final int numberOfRiders;
  final bool sameGender;
  final bool isMatched;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  RideRequest({
    this.id,
    this.userId,
    required this.sourceLatitude,
    required this.sourceLongitude,
    required this.sourceAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationAddress,
    required this.earliestDepartureTime,
    required this.latestArrivalTime,
    required this.maxWalkingTimeMinutes,
    required this.numberOfRiders,
    required this.sameGender,
    this.isMatched = false,
    this.createdAt,
    this.updatedAt,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) => _$RideRequestFromJson(json);
  Map<String, dynamic> toJson() {
    final json = _$RideRequestToJson(this);
    // Ensure all DateTime fields have 'Z' suffix
    if (json['earliestDepartureTime'] != null) {
      json['earliestDepartureTime'] = formatDateTimeToIso8601(earliestDepartureTime);
    }
    if (json['latestArrivalTime'] != null) {
      json['latestArrivalTime'] = formatDateTimeToIso8601(latestArrivalTime);
    }
    if (json['createdAt'] != null) {
      json['createdAt'] = formatDateTimeToIso8601(createdAt!);
    }
    if (json['updatedAt'] != null) {
      json['updatedAt'] = formatDateTimeToIso8601(updatedAt!);
    }
    return json;
  }

  RideRequest copyWith({
    String? id,
    String? userId,
    double? sourceLatitude,
    double? sourceLongitude,
    String? sourceAddress,
    double? destinationLatitude,
    double? destinationLongitude,
    String? destinationAddress,
    DateTime? earliestDepartureTime,
    DateTime? latestArrivalTime,
    int? maxWalkingTimeMinutes,
    int? numberOfRiders,
    bool? sameGender,
    bool? isMatched,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RideRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sourceLatitude: sourceLatitude ?? this.sourceLatitude,
      sourceLongitude: sourceLongitude ?? this.sourceLongitude,
      sourceAddress: sourceAddress ?? this.sourceAddress,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      earliestDepartureTime: earliestDepartureTime ?? this.earliestDepartureTime,
      latestArrivalTime: latestArrivalTime ?? this.latestArrivalTime,
      maxWalkingTimeMinutes: maxWalkingTimeMinutes ?? this.maxWalkingTimeMinutes,
      numberOfRiders: numberOfRiders ?? this.numberOfRiders,
      sameGender: sameGender ?? this.sameGender,
      isMatched: isMatched ?? this.isMatched,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 