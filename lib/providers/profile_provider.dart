import 'package:flutter/foundation.dart';
import 'package:frontend/models/profile.dart';
import 'package:frontend/services/api/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService;
  Profile? _profile;
  List<Profile> _profiles = [];
  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._profileService);

  Profile? get profile => _profile;
  List<Profile> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile(String userId) async {
    debugPrint('Fetching profile for userId: $userId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileService.getProfile(userId);
      debugPrint('Profile fetched successfully: ${_profile?.email}');
      _error = null;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      _error = e.toString();
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllProfiles() async {
    debugPrint('Fetching all profiles');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profiles = await _profileService.getAllProfiles();
      debugPrint('Fetched ${_profiles.length} profiles');
      _error = null;
    } catch (e) {
      debugPrint('Error fetching all profiles: $e');
      _error = e.toString();
      _profiles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String gender,
    String? imageUrl,
  }) async {
    debugPrint('Creating profile for userId: $userId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileService.createProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        gender: gender,
        imageUrl: imageUrl,
      );
      debugPrint('Profile created successfully: ${_profile?.email}');
      _error = null;
    } catch (e) {
      debugPrint('Error creating profile: $e');
      _error = e.toString();
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String gender,
    String? imageUrl,
  }) async {
    debugPrint('Updating profile for userId: $userId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileService.updateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        gender: gender,
        imageUrl: imageUrl,
      );
      debugPrint('Profile updated successfully: ${_profile?.email}');
      _error = null;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProfile(String userId) async {
    debugPrint('Deleting profile for userId: $userId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _profileService.deleteProfile(userId);
      debugPrint('Profile deleted successfully: $userId');
      if (_profile?.userId == userId) {
        _profile = null;
      }
      _profiles.removeWhere((profile) => profile.userId == userId);
      _error = null;
    } catch (e) {
      debugPrint('Error deleting profile: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 