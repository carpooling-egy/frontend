import 'package:flutter/foundation.dart';
import 'package:frontend/services/api/api_service.dart';

class TripService {
  final ApiService _apiService;

  TripService(this._apiService);

  /// Fetch summarized cards for the user
  Future<Map<String, dynamic>> getSummarizedCards(String userId) async {
    final url = 'https://9689-41-43-174-157.ngrok-free.app/trip-management/summarized-cards/C9bep1b4Dua0kxkzEloXX4Fw1wJ3';
    try {
      debugPrint('TripService: Fetching summarized cards for user $userId');
      // Use the full URL, not the baseUrl
      final response = await _apiService.get(url);
      debugPrint('TripService: Got summarized cards: \n$response');
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('TripService: Error fetching summarized cards: $e');
      rethrow;
    }
  }

  /// Fetch detailed card data for a specific card
  Future<Map<String, dynamic>> getDetailedCard({
    required String type,
    required String userId,
    required String cardId,
  }) async {
    if(type.contains('Rider')) {
      type = 'rider-request';
    } else if(type.contains('driver')) {
      type = 'driver-offer';
    } else {
      debugPrint('TripService: Unknown type $type, defaulting to driver');
    }

    final url = 'https://9689-41-43-174-157.ngrok-free.app/trip-management/detailed-card/$type';
    final body = {
      'userId': userId,
      'cardId': cardId,
    };
    try {
      debugPrint('#### TripService: Fetching detailed card for $type, user $userId, card $cardId');
      final response = await _apiService.post(url, body);
      debugPrint('TripService: Got detailed card: \n$response');
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('TripService: Error fetching detailed card: $e');
      rethrow;
    }
  }

  /// Fetch upcoming trips for the user
  Future<List<dynamic>> getUpcomingTrips(String userId) async {
    final url = 'https://9689-41-43-174-157.ngrok-free.app/trip-management/upcomingTrips/$userId';
    try {
      debugPrint('TripService: Fetching upcoming trips for user $userId');
      final response = await _apiService.get(url);
      debugPrint('TripService: Got upcoming trips: \n$response');
      return response as List<dynamic>;
    } catch (e) {
      debugPrint('TripService: Error fetching upcoming trips: $e');
      rethrow;
    }
  }

  /// Fetch pending rider requests for the user
  Future<List<dynamic>> getPendingRiderRequests(String userId) async {
    final url = 'https://9689-41-43-174-157.ngrok-free.app/trip-management/pending-rider-requests/$userId';
    try {
      debugPrint('TripService: Fetching pending rider requests for user $userId');
      final response = await _apiService.get(url);
      debugPrint('TripService: Got pending rider requests: \n$response');
      return response as List<dynamic>;
    } catch (e) {
      debugPrint('TripService: Error fetching pending rider requests: $e');
      rethrow;
    }
  }
} 