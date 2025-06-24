import 'package:flutter/foundation.dart';
import 'package:frontend/models/ride_offer.dart';
import 'package:frontend/services/api/api_service.dart';
import 'dart:convert';
import 'package:frontend/models/ride_request.dart';

class RideService {
  final ApiService _apiService;

  RideService(this._apiService);

  // Mock data for development/testing
  List<Map<String, dynamic>> _getMockRideRequests() {
    debugPrint('RideService: Returning mock ride requests data');
    return [
      // Matched rider request example
      {
        'riderId': 'r12345',
        'tripDate': '2025-06-22T10:30:00Z',
        'pickupLatitude': 30.0444,
        'pickupLongitude': 31.2357,
        'pickupAddress': 'Tahrir Square, Cairo, Egypt',
        'dropoffLatitude': 30.0611,
        'dropoffLongitude': 31.2195,
        'dropoffAddress': 'Zamalek, Cairo, Egypt',
        'pickupTime': '2025-06-22T10:45:00Z',
        'dropoffTime': '2025-06-22T11:15:00Z',
        'driverId': 'd67890',
        'driverName': 'Ahmed Mostafa',
        'driverGender': 'MALE',
        'matched': true,
      },
      // Unmatched rider request example
      {
        'id': 'rdr-req-2',
        'userId': 'user-rdr-2',
        'sourceLatitude': 30.05000000,
        'sourceLongitude': 31.24000000,
        'sourceAddress': 'Tahrir Square',
        'destinationLatitude': 30.01310000,
        'destinationLongitude': 31.20890000,
        'destinationAddress': 'Egyptian Museum',
        'sameGender': false,
        'createdAt': '2025-06-21T21:29:35.328572Z',
        'updatedAt': '2025-06-21T21:29:35.328572Z',
        'earliestDepartureTime': '2025-06-21T22:29:35.328572Z',
        'latestArrivalTime': '2025-06-21T23:29:35.328572Z',
        'maxWalkingTimeMinutes': 5,
        'numberOfRiders': 1,
        'matched': false,
      },

    ];
  }

  List<RideOffer> _getMockRideOffers() {
    debugPrint('RideService: Returning mock ride offers data');
    return [
      // Example with matchedRiders and path fields
      RideOffer(
        id: 'drv-offer-1',
        sourceAddress: 'Cairo Tower',
        destinationAddress: 'Egyptian Museum',
        departureTime: DateTime.parse('2025-06-21T22:29:35.328572Z'),
        maxEstimatedArrivalTime: DateTime.parse('2025-06-21T23:29:35.328572Z'),
        detourTimeMinutes: 15,
        capacity: 3,
        sameGender: false,
        sourceLatitude: 30.0444,
        sourceLongitude: 31.2357,
        destinationLatitude: 30.0131,
        destinationLongitude: 31.2089,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        // Add extra fields as dynamic properties
        extra: {
          'matchedRiders': [
            {
              'riderId': 'user-rdr-1',
              'riderName': 'Placeholder Name',
              'riderGender': 'male',
              'pickupTime': '2025-06-21T22:39:35.328572Z',
              'dropoffTime': '2025-06-21T23:19:35.328572Z',
              'pickupAddress': 'Cairo Opera House',
              'dropoffAddress': 'Egyptian Museum',
            }
          ],
          'path': [
            {
              'type': 'pickup',
              'reqId': 'user-rdr-1',
              'latitude': 30.046,
              'longitude': 31.2365,
            },
            {
              'type': 'dropoff',
              'reqId': 'user-rdr-1',
              'latitude': 30.0131,
              'longitude': 31.2089,
            }
          ]
        },
      ),
    ];
  }

  // Request a ride
  Future<RideRequest> requestRide({
    required double sourceLatitude,
    required double sourceLongitude,
    required String sourceAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationAddress,
    required DateTime earliestDepartureTime,
    required DateTime latestArrivalTime,
    required int maxWalkingTimeMinutes,
    required int numberOfRiders,
    required bool sameGender,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) async {
    debugPrint('RideService: Creating ride request');
    try {
      final rideRequest = RideRequest(
        sourceLatitude: sourceLatitude,
        sourceLongitude: sourceLongitude,
        sourceAddress: sourceAddress,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
        destinationAddress: destinationAddress,
        earliestDepartureTime: earliestDepartureTime,
        latestArrivalTime: latestArrivalTime,
        maxWalkingTimeMinutes: maxWalkingTimeMinutes,
        numberOfRiders: numberOfRiders,
        sameGender: sameGender,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      debugPrint('RideService: Sending data:');
      debugPrint(JsonEncoder.withIndent('  ').convert(rideRequest.toJson()));
      
      final response = await _apiService.post('https://7b9e-197-55-251-232.ngrok-free.app/api/rider-requests', rideRequest.toJson());
      debugPrint('RideService: Got response: $response');
      return RideRequest.fromJson(response);
    } catch (e) {
      debugPrint('RideService: Error creating ride request: $e');
      throw Exception('Failed to create ride request: $e');
    }
  }

  // Offer a ride
  Future<RideOffer> offerRide({
    required double sourceLatitude,
    required double sourceLongitude,
    required String sourceAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationAddress,
    required DateTime departureTime,
    required DateTime maxEstimatedArrivalTime,
    required int detourTimeMinutes,
    required int capacity,
    required bool sameGender,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) async {
    debugPrint('RideService: Creating ride offer');
    try {
      final rideOffer = RideOffer(
        sourceLatitude: sourceLatitude,
        sourceLongitude: sourceLongitude,
        sourceAddress: sourceAddress,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
        destinationAddress: destinationAddress,
        departureTime: departureTime,
        maxEstimatedArrivalTime: maxEstimatedArrivalTime,
        detourTimeMinutes: detourTimeMinutes,
        capacity: capacity,
        sameGender: sameGender,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      debugPrint('RideService: Sending data:');
      debugPrint(JsonEncoder.withIndent('  ').convert(rideOffer.toJson()));
      
      final response = await _apiService.post('https://7b9e-197-55-251-232.ngrok-free.app/api/driver-offers', rideOffer.toJson());
      debugPrint('RideService: Got response: $response');
      return RideOffer.fromJson(response);
    } catch (e) {
      debugPrint('RideService: Error creating ride offer: $e');
      throw Exception('Failed to create ride offer: $e');
    }
  }

  // Get user's ride requests
  Future<List<dynamic>> getUserRideRequests() async {
    debugPrint('RideService: Fetching user ride requests');
    try {
      // Add timeout to prevent infinite loading
      final response = await _apiService.get('/rides/requests/user')
          .timeout(const Duration(seconds: 5));
      debugPrint('RideService: Got response: $response');
      return response as List;
    } catch (e) {
      debugPrint('RideService: Error fetching user ride requests: $e');
      debugPrint('RideService: Returning mock data for ride requests');
      // Return mock data when API fails
      return _getMockRideRequests();
    }
  }

  // Get user's ride offers
  Future<List<RideOffer>> getUserRideOffers() async {
    debugPrint('RideService: Fetching user ride offers');
    try {
      // Add timeout to prevent infinite loading
      final response = await _apiService.get('/rides/offers/user')
          .timeout(const Duration(seconds: 5));
      debugPrint('RideService: Got response: $response');
      return (response as List)
          .map((json) => RideOffer.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('RideService: Error fetching user ride offers: $e');
      debugPrint('RideService: Returning mock data for ride offers');
      // Return mock data when API fails
      return _getMockRideOffers();
    }
  }

  // Accept a ride request
  Future<Map<String, dynamic>> acceptRideRequest(String requestId) async {
    return await _apiService.post('/rides/requests/$requestId/accept', {});
  }

  // Cancel a ride
  Future<void> cancelRide(String rideId) async {
    debugPrint('RideService: Cancelling ride: $rideId');
    try {
      await _apiService.delete('/rides/$rideId');
      debugPrint('RideService: Ride cancelled successfully');
    } catch (e) {
      debugPrint('RideService: Error cancelling ride: $e');
      throw Exception('Failed to cancel ride: $e');
    }
  }

  // Get ride details
  Future<RideOffer> getRideDetails(String rideId) async {
    debugPrint('RideService: Getting ride details: $rideId');
    try {
      final response = await _apiService.get('/rides/$rideId');
      debugPrint('RideService: Got response: $response');
      return RideOffer.fromJson(response);
    } catch (e) {
      debugPrint('RideService: Error getting ride details: $e');
      throw Exception('Failed to get ride details: $e');
    }
  }

  // Get summarized ride request card data
  Future<List<Map<String, dynamic>>> getUserRideRequestCards() async {
    try {
      final requests = await getUserRideRequests();
      return requests.map<Map<String, dynamic>>((req) {
        final isMatched = req['matched'] == true;
        return {
          'id': req['riderId'] ?? req['id'],
          'pickupAddress': req['pickupAddress'] ?? req['sourceAddress'],
          'dropoffAddress': req['dropoffAddress'] ?? req['destinationAddress'],
          'tripDate': req['tripDate'] ?? req['pickupTime'] ?? req['earliestDepartureTime'],
          'matched': isMatched,
          'driverName': isMatched ? req['driverName'] : null,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get full ride request detail by id (mock only for now)
  Future<Map<String, dynamic>?> getRideRequestDetail(String id) async {
    try {
      final requests = await getUserRideRequests();
      return requests.firstWhere(
        (req) => (req['riderId'] ?? req['id']) == id,
        orElse: () => null,
      );
    } catch (e) {
      return null;
    }
  }
} 