import 'coordinate.dart';

class LabeledWaypoint {
  static int _counter = 1;

  final Coordinate coord;
  final String label;

  LabeledWaypoint({
    required this.coord,
    String? label,
  }) : label = label ?? 'label${_counter++}';

  @override
  String toString() {
    return '$label: $coord';
  }
}