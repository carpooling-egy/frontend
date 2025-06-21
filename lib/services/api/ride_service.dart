import 'package:flutter/foundation.dart';
import 'package:frontend/models/ride_offer.dart';
import 'package:frontend/services/api/api_service.dart';
import 'dart:convert';
import 'package:frontend/models/ride_request.dart';

class RideService {
  final ApiService _apiService;

  RideService(this._apiService);

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
    required bool allowsSmoking,
    required bool allowsPets,
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
        allowsSmoking: allowsSmoking,
        allowsPets: allowsPets,
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
    required bool allowsSmoking,
    required bool allowsPets,
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
        allowsSmoking: allowsSmoking,
        allowsPets: allowsPets,
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

  // Get available rides
  Future<List<RideOffer>> getAvailableRides({
    String? startLocation,
    String? endLocation,
    DateTime? date,
  }) async {
    debugPrint('RideService: Getting available rides');
    try {
      final queryParams = {
        if (startLocation != null) 'startLocation': startLocation,
        if (endLocation != null) 'endLocation': endLocation,
        if (date != null) 'date': date.toIso8601String(),
      };
      final queryString = Uri(queryParameters: queryParams).query;
      final response = await _apiService.get('/rides/available?$queryString');
      debugPrint('RideService: Got response: $response');
      return (response as List).map((json) => RideOffer.fromJson(json)).toList();
    } catch (e) {
      debugPrint('RideService: Error getting available rides: $e');
      throw Exception('Failed to get available rides: $e');
    }
  }

  // Get user's ride requests
  Future<List<dynamic>> getUserRideRequests() async {
    debugPrint('RideService: Fetching user ride requests');
    try {
      final response = await _apiService.get('/rides/requests/user');
      debugPrint('RideService: Got response: $response');
      return response as List;
    } catch (e) {
      debugPrint('RideService: Error fetching user ride requests: $e');
      throw Exception('Failed to fetch user ride requests: $e');
    }
  }

  // Get user's ride offers
  Future<List<RideOffer>> getUserRideOffers() async {
    debugPrint('RideService: Fetching user ride offers');
    try {
      final response = await _apiService.get('/rides/offers/user');
      debugPrint('RideService: Got response: $response');
      return (response as List)
          .map((json) => RideOffer.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('RideService: Error fetching user ride offers: $e');
      throw Exception('Failed to fetch user ride offers: $e');
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
} 