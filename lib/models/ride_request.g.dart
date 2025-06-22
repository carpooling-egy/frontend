// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RideRequest _$RideRequestFromJson(Map<String, dynamic> json) => RideRequest(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      sourceLatitude: (json['sourceLatitude'] as num).toDouble(),
      sourceLongitude: (json['sourceLongitude'] as num).toDouble(),
      sourceAddress: json['sourceAddress'] as String,
      destinationLatitude: (json['destinationLatitude'] as num).toDouble(),
      destinationLongitude: (json['destinationLongitude'] as num).toDouble(),
      destinationAddress: json['destinationAddress'] as String,
      earliestDepartureTime:
          DateTime.parse(json['earliestDepartureTime'] as String),
      latestArrivalTime: DateTime.parse(json['latestArrivalTime'] as String),
      maxWalkingTimeMinutes: (json['maxWalkingTimeMinutes'] as num).toInt(),
      numberOfRiders: (json['numberOfRiders'] as num).toInt(),
      sameGender: json['sameGender'] as bool,
      isMatched: json['isMatched'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RideRequestToJson(RideRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'sourceLatitude': instance.sourceLatitude,
      'sourceLongitude': instance.sourceLongitude,
      'sourceAddress': instance.sourceAddress,
      'destinationLatitude': instance.destinationLatitude,
      'destinationLongitude': instance.destinationLongitude,
      'destinationAddress': instance.destinationAddress,
      'earliestDepartureTime': instance.earliestDepartureTime.toIso8601String(),
      'latestArrivalTime': instance.latestArrivalTime.toIso8601String(),
      'maxWalkingTimeMinutes': instance.maxWalkingTimeMinutes,
      'numberOfRiders': instance.numberOfRiders,
      'sameGender': instance.sameGender,
      'isMatched': instance.isMatched,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
