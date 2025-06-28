import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/place_suggestion.dart';

class GeocodingService {
  static const _base = 'https://api.mapbox.com/search/geocode/v6/forward';

  Future<List<PlaceSuggestion>> autocomplete(
    String query, {
    int limit = 6,
  }) async {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    if (token == null || token.isEmpty) {
      throw StateError('Missing MAPBOX_ACCESS_TOKEN in .env');
    }

    final uri = Uri.parse(
      '$_base'
      '?q=${Uri.encodeComponent(query)}'
      '&autocomplete=true'
      '&fuzzyMatch=true'
      '&limit=$limit'
      '&language=ar'
      '&country=EG'
      '&access_token=$token',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final feats =
        (jsonDecode(res.body)['features'] as List<dynamic>? ?? <dynamic>[])
            .cast<Map<String, dynamic>>();

    return feats
        .map((f) {
          try {
            return PlaceSuggestion.fromJson(f);
          } catch (_) {
            return null;
          }
        })
        .whereType<PlaceSuggestion>()
        .toList(growable: false);
  }
}
