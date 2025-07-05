import 'package:flutter/foundation.dart';
import 'package:frontend/models/profile.dart';
import 'package:frontend/services/api/api_service.dart';

class ProfileService {
  final ApiService _apiService;

  final String _baseUrl = 'http://10.0.2.2:8080/api';

  ProfileService(this._apiService);

  Future<Profile> getProfile(String userId) async {
    debugPrint('ProfileService: Getting profile for userId: $userId');
    try {
      final response = await _apiService.get('$_baseUrl/profiles/user/$userId');
      debugPrint('ProfileService: Got response: $response');
      return Profile.fromJson(response);
    } catch (e) {
      debugPrint('ProfileService: Error getting profile: $e');
      throw Exception('Failed to get profile: $e');
    }
  }

  Future<List<Profile>> getAllProfiles() async {
    debugPrint('ProfileService: Getting all profiles');
    try {
      final response = await _apiService.get('$_baseUrl/profiles');
      debugPrint('ProfileService: Got response: $response');
      return (response as List).map((json) => Profile.fromJson(json)).toList();
    } catch (e) {
      debugPrint('ProfileService: Error getting all profiles: $e');
      throw Exception('Failed to get all profiles: $e');
    }
  }

  Future<Profile> createProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String gender,
    String? imageUrl,
  }) async {
    debugPrint('ProfileService: Creating profile for userId: $userId');
    try {
      final data = {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'imageUrl': imageUrl,
      };
      debugPrint('ProfileService: Sending data: $data');

      final response = await _apiService.post('$_baseUrl/profiles', data);
      debugPrint('ProfileService: Got response: $response');
      return Profile.fromJson(response);
    } catch (e) {
      debugPrint('ProfileService: Error creating profile: $e');
      throw Exception('Failed to create profile: $e');
    }
  }

  Future<Profile> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String gender,
    String? imageUrl,
  }) async {
    debugPrint('ProfileService: Updating profile for userId: $userId');
    try {
      final data = {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'imageUrl': imageUrl,
      };
      debugPrint('ProfileService: Sending data: $data');

      final response = await _apiService.put('$_baseUrl/profiles/user/$userId', data);
      debugPrint('ProfileService: Got response: $response');
      return Profile.fromJson(response);
    } catch (e) {
      debugPrint('ProfileService: Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> deleteProfile(String userId) async {
    debugPrint('ProfileService: Deleting profile for userId: $userId');
    try {
      await _apiService.delete('/profiles/user/$userId');
      debugPrint('ProfileService: Profile deleted successfully');
    } catch (e) {
      debugPrint('ProfileService: Error deleting profile: $e');
      throw Exception('Failed to delete profile: $e');
    }
  }

  Future<String> getUserGender(String userId) async {
    debugPrint('ProfileService: Getting gender for userId: $userId');
    try {
      final response = await _apiService.get('$_baseUrl/profiles/gender/$userId');
      debugPrint('ProfileService: Got response: $response');
      return response['gender'] as String;
    } catch (e) {
      debugPrint('ProfileService: Error getting gender: $e');
      throw Exception('Failed to get gender: $e');
    }
  }
} 