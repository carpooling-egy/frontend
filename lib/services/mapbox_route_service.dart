// lib/services/route/mapbox_route_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../models/coordinate.dart';
import '../../models/route_geometry.dart'; // route_geometry.dart defines your original Route class
import 'iroute_service.dart';

class MapboxRouteService implements IRouteService {
  static const _base = 'https://api.mapbox.com/directions/v5/mapbox/driving';

  @override
  Future<Route> getRoute({required List<Coordinate> waypoints}) async {
    if (waypoints.length < 2) {
      throw ArgumentError('Need at least 2 waypoints');
    }

    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    if (token.isEmpty) throw StateError('Missing MAPBOX_ACCESS_TOKEN');

    final coordString = waypoints.map((c) => c.toPair()).join(';');

    final uri = Uri.parse(
      '$_base/$coordString'
          '?overview=full'
          '&geometries=geojson'
          '&steps=true'
          '&access_token=$token',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Mapbox route HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final routeData = (data['routes'] as List).first as Map<String, dynamic>;

    // Split into legs, each a List<Coordinate>
    final legsJson = (routeData['legs'] as List).cast<Map<String, dynamic>>();
    final coordsPerLeg = legsJson.map((legJson) {
      return (legJson['geometry']['coordinates'] as List)
          .cast<List>()
          .map((c) => Coordinate.fromList(c))
          .toList(growable: false);
    }).toList(growable: false);

    // total distance and duration already in routeData
    final totalDistance = (routeData['distance'] as num).toDouble();
    final totalDuration = (routeData['duration'] as num).toDouble();

    return Route(
      coords: coordsPerLeg,
      distanceMeters: totalDistance,
      durationSeconds: totalDuration,
    );
  }
}
