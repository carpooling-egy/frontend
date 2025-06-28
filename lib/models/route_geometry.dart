import 'coordinate.dart';

class Route {
  final List<List<Coordinate>> coords;
  final double distanceMeters;
  final double durationSeconds;

  const Route({
    required this.coords,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}
