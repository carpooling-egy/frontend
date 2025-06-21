// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RideOffer _$RideOfferFromJson(Map<String, dynamic> json) => RideOffer(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      sourceLatitude: (json['sourceLatitude'] as num).toDouble(),
      sourceLongitude: (json['sourceLongitude'] as num).toDouble(),
      sourceAddress: json['sourceAddress'] as String,
      destinationLatitude: (json['destinationLatitude'] as num).toDouble(),
      destinationLongitude: (json['destinationLongitude'] as num).toDouble(),
      destinationAddress: json['destinationAddress'] as String,
      departureTime: DateTime.parse(json['departureTime'] as String),
      maxEstimatedArrivalTime:
          DateTime.parse(json['maxEstimatedArrivalTime'] as String),
      detourTimeMinutes: (json['detourTimeMinutes'] as num).toInt(),
      capacity: (json['capacity'] as num).toInt(),
      currentNumberOfRequests:
          (json['currentNumberOfRequests'] as num?)?.toInt() ?? 0,
      sameGender: json['sameGender'] as bool,
      allowsSmoking: json['allowsSmoking'] as bool,
      allowsPets: json['allowsPets'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RideOfferToJson(RideOffer instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'sourceLatitude': instance.sourceLatitude,
      'sourceLongitude': instance.sourceLongitude,
      'sourceAddress': instance.sourceAddress,
      'destinationLatitude': instance.destinationLatitude,
      'destinationLongitude': instance.destinationLongitude,
      'destinationAddress': instance.destinationAddress,
      'departureTime': instance.departureTime.toIso8601String(),
      'maxEstimatedArrivalTime':
          instance.maxEstimatedArrivalTime.toIso8601String(),
      'detourTimeMinutes': instance.detourTimeMinutes,
      'capacity': instance.capacity,
      'currentNumberOfRequests': instance.currentNumberOfRequests,
      'sameGender': instance.sameGender,
      'allowsSmoking': instance.allowsSmoking,
      'allowsPets': instance.allowsPets,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
