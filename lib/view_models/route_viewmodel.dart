import 'package:flutter/cupertino.dart' hide Route;
import 'package:provider/provider.dart';
import '../models/coordinate.dart';
import '../services/iroute_service.dart';
import '../models/route_geometry.dart';

class RouteViewModel extends ChangeNotifier {
  final IRouteService _router;

  RouteViewModel(this._router);

  Route? _route;
  Route? get route => _route;

  Future<void> fetchRoute({required List<Coordinate> waypoints}) async {
    _route = await _router.getRoute(waypoints: waypoints);
    notifyListeners();
  }

  void clear() {
    _route = null;
    notifyListeners();
  }
}
