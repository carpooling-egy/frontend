import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/place_suggestion.dart';
import '../services/geocoding_service.dart';

class SearchViewModel extends ChangeNotifier {
  final _svc = GeocodingService();
  final _debounce = const Duration(milliseconds: 250);
  Timer? _timer;

  bool _loading = false;
  List<PlaceSuggestion> _items = [];

  bool get loading => _loading;
  List<PlaceSuggestion> get items => _items;

  void onQueryChanged(String q) {
    _timer?.cancel();
    if (q.trim().isEmpty) {
      _items = [];
      notifyListeners();
      return;
    }

    _timer = Timer(_debounce, () async {
      _loading = true;
      notifyListeners();
      try {
        _items = await _svc.autocomplete(q);
      } finally {
        _loading = false;
        notifyListeners();
      }
    });
  }

  /// Hide the dropdown after the user picks a suggestion.
  void clearSuggestions() {
    _items = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
