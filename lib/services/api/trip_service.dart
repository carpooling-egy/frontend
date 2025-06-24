import 'package:flutter/foundation.dart';
import 'package:frontend/services/api/api_service.dart';

class TripService {
  final ApiService _apiService;

  TripService(this._apiService);

  /// Fetch summarized cards for the user
  Future<Map<String, dynamic>> getSummarizedCards(String userId) async {
    final url = 'https://0137-197-55-230-72.ngrok-free.app/trip-management/summarized-cards/C9bep1b4Dua0kxkzEloXX4Fw1wJ3';
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
    final url = 'http://trip-management/detailed-card/$type/';
    final body = {
      'userId': userId,
      'cardId': cardId,
    };
    try {
      debugPrint('TripService: Fetching detailed card for $type, user $userId, card $cardId');
      final response = await _apiService.post(url, body);
      debugPrint('TripService: Got detailed card: \n$response');
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('TripService: Error fetching detailed card: $e');
      rethrow;
    }
  }
} 