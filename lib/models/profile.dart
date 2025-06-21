import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  final String email;
  final String userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String gender;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Profile({
    required this.email,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.gender,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  Profile copyWith({
    String? email,
    String? userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? gender,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      email: email ?? this.email,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 