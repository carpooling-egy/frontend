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

    // Safely check if 'routes' exists and is not empty
    final routes = data['routes'] as List?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No route found.');
    }
    
    final routeData = routes.first as Map<String, dynamic>;

    // --- Start of Modified Code ---

    // Get the main geometry object from the route itself.
    final geometry = routeData['geometry'] as Map<String, dynamic>?;

    // Create a list to hold the coordinates for the entire route.
    final List<Coordinate> routeCoordinates = [];

    // Safely check if geometry and its coordinates exist.
    if (geometry != null && geometry['coordinates'] != null) {
      final coordinates = geometry['coordinates'] as List;
      
      // Convert the raw coordinates into your custom Coordinate objects.
      for (final c in coordinates) {
        routeCoordinates.add(Coordinate.fromList(c as List));
      }
    }

    if (routeCoordinates.isEmpty) {
      throw Exception('No valid coordinates found in the route geometry.');
    }
    
    // --- End of Modified Code ---

    // total distance and duration already in routeData
    final totalDistance = (routeData['distance'] as num).toDouble();
    final totalDuration = (routeData['duration'] as num).toDouble();

    // The `Route` model expects `coords` to be a `List<List<Coordinate>>`.
    // Since we now have one list of coordinates for the whole route,
    // we wrap it in another list to match the model.
    return Route(
      coords: [routeCoordinates],
      distanceMeters: totalDistance,
      durationSeconds: totalDuration,
    );
  }
}