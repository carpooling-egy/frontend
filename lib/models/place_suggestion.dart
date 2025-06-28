class PlaceSuggestion {
  final String label;
  final String name;
  final double lat;
  final double lon;

  PlaceSuggestion({
    required this.label,
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final props  = json['properties'] as Map<String, dynamic>? ?? {};
    final geom   = json['geometry']   as Map<String, dynamic>? ?? {};
    final coords = geom['coordinates'] as List?;

    if (props['full_address'] == null ||
        props['name'] == null ||
        coords == null ||
        coords.length < 2) {
      throw const FormatException('Missing fields in geocoding feature');
    }

    return PlaceSuggestion(
      label: props['full_address'],
      name : props['name'],
      lon  : (coords[0] as num).toDouble(),
      lat  : (coords[1] as num).toDouble(),
    );
  }
}