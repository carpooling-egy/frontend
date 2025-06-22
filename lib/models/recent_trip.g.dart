// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentTrip _$RecentTripFromJson(Map<String, dynamic> json) => RecentTrip(
      id: json['id'] as String,
      type: json['type'] as String,
      userRole: json['userRole'] as String,
      source: json['source'] as String,
      destination: json['destination'] as String,
      departureTime: DateTime.parse(json['departureTime'] as String),
      matched: json['matched'] as bool,
      remainingCapacity: (json['remainingCapacity'] as num?)?.toInt(),
      matchedRiders: (json['matchedRiders'] as List<dynamic>?)
          ?.map((e) => MatchedRider.fromJson(e as Map<String, dynamic>))
          .toList(),
      driver: json['driver'] == null
          ? null
          : DriverInfo.fromJson(json['driver'] as Map<String, dynamic>),
      pickupTime: json['pickupTime'] == null
          ? null
          : DateTime.parse(json['pickupTime'] as String),
    );

Map<String, dynamic> _$RecentTripToJson(RecentTrip instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'userRole': instance.userRole,
      'source': instance.source,
      'destination': instance.destination,
      'departureTime': instance.departureTime.toIso8601String(),
      'matched': instance.matched,
      'remainingCapacity': instance.remainingCapacity,
      'matchedRiders': instance.matchedRiders?.map((e) => e.toJson()).toList(),
      'driver': instance.driver?.toJson(),
      'pickupTime': instance.pickupTime?.toIso8601String(),
    };

MatchedRider _$MatchedRiderFromJson(Map<String, dynamic> json) => MatchedRider(
      id: json['id'] as String,
      name: json['name'] as String,
      pickupTime: json['pickupTime'] == null
          ? null
          : DateTime.parse(json['pickupTime'] as String),
    );

Map<String, dynamic> _$MatchedRiderToJson(MatchedRider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'pickupTime': instance.pickupTime?.toIso8601String(),
    };

DriverInfo _$DriverInfoFromJson(Map<String, dynamic> json) => DriverInfo(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$DriverInfoToJson(DriverInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
