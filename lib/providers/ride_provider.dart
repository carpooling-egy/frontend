import 'package:flutter/foundation.dart';
import 'package:frontend/models/ride_offer.dart';
import 'package:frontend/services/api/ride_service.dart';

class RideProvider with ChangeNotifier {
  final RideService _rideService;
  List<RideOffer> _userRideOffers = [];
  List<dynamic> _userRideRequests = [];
  bool _isLoading = false;
  String? _error;

  RideProvider(this._rideService);

  List<RideOffer> get userRideOffers => _userRideOffers;
  List<dynamic> get userRideRequests => _userRideRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserRideOffers() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final offers = await _rideService.getUserRideOffers();
      _userRideOffers = offers;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUserRideRequests() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final requests = await _rideService.getUserRideRequests();
      _userRideRequests = requests;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
} 