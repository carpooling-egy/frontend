import '../../models/coordinate.dart';
import '../../models/route_geometry.dart';

abstract class IRouteService {
  Future<Route> getRoute({required List<Coordinate> waypoints});
}
