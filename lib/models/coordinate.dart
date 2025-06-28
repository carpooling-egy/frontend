class Coordinate {
  final double lon;
  final double lat;

  const Coordinate(this.lon, this.lat);

  factory Coordinate.fromList(List<dynamic> pair) {
    return Coordinate(
      (pair[0] as num).toDouble(),
      (pair[1] as num).toDouble(),
    );
  }

  List<double> toList() => [lon, lat];

  @override
  String toString() => '[$lon, $lat]';
}

extension CoordinateFormatting on Coordinate {
  String toPair() => '$lon,$lat';
}
