import 'package:flutter/foundation.dart';
import 'package:frontend/services/api/trip_service.dart';

class RideProvider with ChangeNotifier {
  final TripService _tripService;

  List<dynamic> _summarizedCards = [];
  Map<String, dynamic>? _detailedCard;
  bool _isLoadingSummarized = false;
  bool _isLoadingDetail = false;
  String? _error;

  RideProvider(this._tripService);

  List<dynamic> get summarizedCards => _summarizedCards;
  Map<String, dynamic>? get detailedCard => _detailedCard;
  bool get isLoadingSummarized => _isLoadingSummarized;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;

  Future<void> loadSummarizedCards(String userId) async {
    _isLoadingSummarized = true;
    _error = null;
    notifyListeners();
    try {
      final cards = await _tripService.getSummarizedCards(userId);
      // Flatten all card types into a single list for display
      _summarizedCards = [];
      cards.forEach((key, value) {
        if (value is List) {
          for (var card in value) {
            card['type'] = key; // Attach type for later use
            _summarizedCards.add(card);
          }
        }
      });

      _isLoadingSummarized = false;
      notifyListeners();
    } catch (e) {
      _isLoadingSummarized = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadDetailedCard({
    required String type,
    required String userId,
    required String cardId,
  }) async {
    _isLoadingDetail = true;
    _error = null;
    notifyListeners();
    try {
      final detail = await _tripService.getDetailedCard(
        type: type,
        userId: userId,
        cardId: cardId,
      );
      _detailedCard = detail;
      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _isLoadingDetail = false;
      _error = e.toString();
      notifyListeners();
    }
  }
} 