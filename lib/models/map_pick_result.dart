// models/map_pick_result.dart

import 'package:frontend/models/place_suggestion.dart';

class MapPickResult {
  final PlaceSuggestion source;
  final PlaceSuggestion destination;

  MapPickResult({
    required this.source,
    required this.destination,
  });
}
