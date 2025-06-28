import 'package:flutter/foundation.dart';

import '../models/route_geometry.dart';

class RouteInfoViewModel extends ChangeNotifier {
  String _distance = '';
  String _eta = '';

  String get distance => _distance;
  String get eta => _eta;

  void updateFromRoute(Route? r) {
    if (r == null) {
      _distance = _eta = '';
    } else {
      _distance = '${(r.distanceMeters / 1000).toStringAsFixed(1)} km';
      final d = Duration(seconds: r.durationSeconds.round());
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      _eta = h > 0 ? '${h}h ${m}m' : '${m}m';
    }
    notifyListeners();
  }

  void clear() {
    _distance = '';
    _eta = '';
    notifyListeners();
  }
}
