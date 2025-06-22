// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detailed_trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailedTrip _$DetailedTripFromJson(Map<String, dynamic> json) => DetailedTrip(
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
      path: (json['path'] as List<dynamic>?)
          ?.map((e) => LatLngPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      vehicle: json['vehicle'] == null
          ? null
          : VehicleInfo.fromJson(json['vehicle'] as Map<String, dynamic>),
      pickupTime: json['pickupTime'] == null
          ? null
          : DateTime.parse(json['pickupTime'] as String),
    );

Map<String, dynamic> _$DetailedTripToJson(DetailedTrip instance) =>
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
      'path': instance.path?.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'vehicle': instance.vehicle?.toJson(),
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
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$DriverInfoToJson(DriverInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
    };

VehicleInfo _$VehicleInfoFromJson(Map<String, dynamic> json) => VehicleInfo(
      make: json['make'] as String,
      model: json['model'] as String,
      color: json['color'] as String,
      plate: json['plate'] as String,
    );

Map<String, dynamic> _$VehicleInfoToJson(VehicleInfo instance) =>
    <String, dynamic>{
      'make': instance.make,
      'model': instance.model,
      'color': instance.color,
      'plate': instance.plate,
    };

LatLngPoint _$LatLngPointFromJson(Map<String, dynamic> json) => LatLngPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$LatLngPointToJson(LatLngPoint instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };
