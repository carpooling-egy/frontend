import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");

    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    if (token == null || token.isEmpty) {
      throw Exception("MAPBOX_ACCESS_TOKEN is missing in .env");
    }

    MapboxOptions.setAccessToken(token);
  }
}
