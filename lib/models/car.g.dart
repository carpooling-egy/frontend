// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Car _$CarFromJson(Map<String, dynamic> json) => Car(
      id: json['id'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      licensePlate: json['licensePlate'] as String,
      year: (json['year'] as num).toInt(),
      color: json['color'] as String,
      seats: (json['seats'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CarToJson(Car instance) => <String, dynamic>{
      'id': instance.id,
      'make': instance.make,
      'model': instance.model,
      'licensePlate': instance.licensePlate,
      'year': instance.year,
      'color': instance.color,
      'seats': instance.seats,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
