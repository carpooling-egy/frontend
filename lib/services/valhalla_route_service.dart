// lib/services/route/valhalla_route_service.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../models/coordinate.dart';
import '../../models/route_geometry.dart';
import '../utils/polyline6_decoder.dart';
import 'iroute_service.dart';

class ValhallaRouteService implements IRouteService {
  late final String _base;

  ValhallaRouteService() {
    final raw = dotenv.env['VALHALLA_BASE'] ?? '';
    if (raw.isEmpty) throw StateError('Missing VALHALLA_BASE');

    final host = raw.startsWith('localhost') && Platform.isAndroid
        ? '10.0.2.2${raw.substring('localhost'.length)}'
        : raw;

    _base = host.startsWith('http') ? host : 'http://$host';
  }

  @override
  Future<Route> getRoute({required List<Coordinate> waypoints}) async {
    if (waypoints.length < 2) {
      throw ArgumentError('Need at least 2 waypoints');
    }

    final uri = Uri.parse('$_base/route?costing=auto');
    final body = _buildRequestBody(waypoints);

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Valhalla HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data.containsKey('error')) {
      throw Exception('Valhalla error: ${data['error']}');
    }

    final trip = data['trip'] as Map<String, dynamic>;
    final summary = trip['summary'] as Map<String, dynamic>;
    final legs = (trip['legs'] as List).cast<Map<String, dynamic>>();

    // Decode each leg separately
    final coordsPerLeg = legs.map((leg) {
      final poly6 = leg['shape'] as String;
      final decoded = decodePolyline(poly6, precision: 6);
      return decoded;
    }).toList(growable: false);

    // summary['length'] is in kilometers
    final totalDistance = ((summary['length'] as num) * 1000).toDouble();
    final totalDuration = (summary['time'] as num).toDouble();

    return Route(
      coords: coordsPerLeg,
      distanceMeters: totalDistance,
      durationSeconds: totalDuration,
    );
  }

  Map<String, dynamic> _buildRequestBody(List<Coordinate> waypoints) =>
      {
        'locations': [
          for (final c in waypoints) {'lat': c.lat, 'lon': c.lon}
        ],
        'costing_options': {
          'auto': {'shortest': true},
        },
        'directions_options': {'units': 'kilometers'},
        'units': 'kilometers',
        'shape_format': 'polyline6',
      };
}
