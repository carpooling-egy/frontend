import 'package:flutter/foundation.dart';
import 'package:frontend/models/ride_offer.dart';
import 'package:frontend/services/api/api_service.dart';
import 'dart:convert';
import 'package:frontend/models/ride_request.dart';
import 'package:frontend/models/recent_trip.dart';
import 'package:frontend/models/detailed_trip.dart';

class RideService {
  final ApiService _apiService;

  RideService(this._apiService);

  // Mock data for development/testing
  List<Map<String, dynamic>> _getMockRideRequests() {
    debugPrint('RideService: Returning mock ride requests data');
    return [
      // Matched rider request example
      {
        'createdAt': '2025-06-22T10:30:00Z', // new
        'pickupLatitude': 30.0444,
        'pickupLongitude': 31.2357,
        'pickupAddress': 'Tahrir Square, Cairo, Egypt',
        'dropoffLatitude': 30.0611,
        'dropoffLongitude': 31.2195,
        'dropoffAddress': 'Zamalek, Cairo, Egypt',
        'pickupTime': '2025-06-22T10:45:00Z',
        'dropoffTime': '2025-06-22T11:15:00Z',
        'driverId': 'd67890', // doesn't exist
        'driverName': 'Ahmed Mostafa', // doesn't exist
        'driverFirstName': 'Ahmed', // new
        'driverLastName': 'Mostafa', // new
        'driverGender': 'MALE',
        'sameGender': false, // new
        'matched': true,
      },
      // Unmatched rider request example
      {
        'id': 'rdr-req-2',
        'userId': 'user-rdr-2',  // doesn't exist
        'sourceLatitude': 30.05000000,
        'sourceLongitude': 31.24000000,
        'sourceAddress': 'Tahrir Square',
        'destinationLatitude': 30.01310000,
        'destinationLongitude': 31.20890000,
        'destinationAddress': 'Egyptian Museum',
        'sameGender': false,
        'createdAt': '2025-06-21T21:29:35.328572Z',
        'updatedAt': '2025-06-21T21:29:35.328572Z', // doesn't exist
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
      // Example with matchedRiders and path fields, but lat/long values swapped
      RideOffer(
        id: 'drv-offer-1',
        sourceAddress: 'Cairo Tower',
        destinationAddress: 'Egyptian Museum',
        departureTime: DateTime.parse('2025-06-21T22:29:35.328572Z'),
        maxEstimatedArrivalTime: DateTime.parse('2025-06-21T23:29:35.328572Z'),
        detourTimeMinutes: 15,
        capacity: 3,
        sameGender: false,
        // swapped: lat ← old long, long ← old lat
        sourceLatitude: 31.198691494191976,
        sourceLongitude: 29.908174576147985,
        destinationLatitude: 31.16945470639824,
        destinationLongitude: 29.886436679686113,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        extra: {
          'matchedRiders': [
            {
              'riderId': 'user-rdr-1', // doesn't exist
              'riderName': 'Ali Mansour', // doesn't exist
              'riderFirstName': 'Placeholder Name', // new
              'riderLastName': 'Placeholder Last Name',  // new
              'riderGender': 'male',
              'pickupTime': '2025-06-21T22:35:00Z',  // doesn't exist
              'dropoffTime': '2025-06-21T22:50:00Z', // doesn't exist
              'pickupLatitude': 30.04600000, // new
              'pickupLongitude': 31.23650000, // new
              'pickupAddress': 'Waypoint 1',
              'dropoffLatitude': 30.01310000, // new
              'dropoffLongitude': 31.20890000, // new
              'dropoffAddress': 'Waypoint 3',
            }
          ],
          'path': [
            {
              'type': 'pickup',
              'reqId': 'user-rdr-1',
              'latitude': 31.19915432414726,
              'longitude': 29.90320377188607,
            },
            {
              'type': 'dropoff',
              'reqId': 'user-rdr-1',
              'latitude': 31.189595445926358,
              'longitude': 29.892563755897868,
            },
          ]
        },
      ),
    ];
  }

  // Fetch recent activities (offers and requests) from backend
  Future<List<RecentTrip>> fetchRecentActivities() async {
    try {
      final response = await _apiService.get('/activities');
      if (response is List) {
        return response.map((json) => RecentTrip.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      debugPrint('RideService: Error fetching recent activities: $e');
      throw Exception('Failed to fetch recent activities: $e');
    }
  }

  final String _baseUrl = 'https://metal-queens-dress.loca.lt/api';

  // Request a ride
  Future<void> requestRide({
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
      
      final response = await _apiService.post('$_baseUrl/rider-requests', rideRequest.toJson());
      debugPrint('RideService: Got response: $response');
      // return RideRequest.fromJson(response);
    } catch (e) {
      debugPrint('RideService: Error creating ride request: $e');
      throw Exception('Failed to create ride request: $e');
    }
  }

  // Offer a ride
  Future<void> offerRide({
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
      
      final response = await _apiService.post('$_baseUrl/driver-offers', rideOffer.toJson());
      debugPrint('RideService: Got response: $response');
      // return RideOffer.fromJson(response);
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