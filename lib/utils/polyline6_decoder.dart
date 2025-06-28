import '../models/coordinate.dart';
import 'dart:math' as math;

List<Coordinate> decodePolyline(String input, {int precision = 6}) {
  final coordinates = <Coordinate>[];
  final factor = math.pow(10, precision).toDouble();

  int index = 0;
  int lat = 0, lon = 0;

  while (index < input.length) {
    lat += _decodeComponent(input, ref: index);
    index = _nextIndex;

    lon += _decodeComponent(input, ref: index);
    index = _nextIndex;

    coordinates.add(Coordinate(lon / factor, lat / factor));
  }

  return coordinates;
}

int _nextIndex = 0;

int _decodeComponent(String input, {required int ref}) {
  int result = 0;
  int shift = 0;
  int b;

  _nextIndex = ref;

  do {
    b = input.codeUnitAt(_nextIndex++) - 63;
    result |= (b & 0x1F) << shift;
    shift += 5;
  } while (b >= 0x20 && _nextIndex < input.length);

  return (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
}
