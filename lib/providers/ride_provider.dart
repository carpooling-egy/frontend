import 'package:flutter/foundation.dart';
import 'package:frontend/models/ride_offer.dart';
import 'package:frontend/services/api/ride_service.dart';

class RideProvider with ChangeNotifier {
  final RideService _rideService;
  List<RideOffer> _userRideOffers = [];
  List<dynamic> _userRideRequests = [];
  bool _isLoadingOffers = false;
  bool _isLoadingRequests = false;
  String? _error;

  RideProvider(this._rideService);

  List<RideOffer> get userRideOffers => _userRideOffers;
  List<dynamic> get userRideRequests => _userRideRequests;
  bool get isLoading => _isLoadingOffers || _isLoadingRequests;
  String? get error => _error;

  Future<void> loadUserRideOffers() async {
    try {
      _isLoadingOffers = true;
      _error = null; // Clear any previous errors
      notifyListeners();
      
      final offers = await _rideService.getUserRideOffers();
      _userRideOffers = offers;
      
      _isLoadingOffers = false;
      notifyListeners();
    } catch (e) {
      _isLoadingOffers = false;
      // Don't set error when using mock data
      if (!e.toString().contains('mock data')) {
        _error = e.toString();
      }
      notifyListeners();
    }
  }

  Future<void> loadUserRideRequests() async {
    try {
      _isLoadingRequests = true;
      _error = null; // Clear any previous errors
      notifyListeners();
      
      final requests = await _rideService.getUserRideRequests();
      _userRideRequests = requests;
      
      _isLoadingRequests = false;
      notifyListeners();
    } catch (e) {
      _isLoadingRequests = false;
      // Don't set error when using mock data
      if (!e.toString().contains('mock data')) {
        _error = e.toString();
      }
      notifyListeners();
    }
  }

  // Load both offers and requests together
  Future<void> loadAllUserRides() async {
    try {
      _isLoadingOffers = true;
      _isLoadingRequests = true;
      _error = null;
      notifyListeners();
      
      // Load both in parallel
      await Future.wait([
        _loadUserRideOffersInternal(),
        _loadUserRideRequestsInternal(),
      ]);
      
    } catch (e) {
      _isLoadingOffers = false;
      _isLoadingRequests = false;
      if (!e.toString().contains('mock data')) {
        _error = e.toString();
      }
      notifyListeners();
    }
  }

  Future<void> _loadUserRideOffersInternal() async {
    try {
      final offers = await _rideService.getUserRideOffers();
      _userRideOffers = offers;
      _isLoadingOffers = false;
      notifyListeners();
    } catch (e) {
      _isLoadingOffers = false;
      if (!e.toString().contains('mock data')) {
        _error = e.toString();
      }
      notifyListeners();
    }
  }

  Future<void> _loadUserRideRequestsInternal() async {
    try {
      final requests = await _rideService.getUserRideRequests();
      _userRideRequests = requests;
      _isLoadingRequests = false;
      notifyListeners();
    } catch (e) {
      _isLoadingRequests = false;
      if (!e.toString().contains('mock data')) {
        _error = e.toString();
      }
      notifyListeners();
    }
  }
} 