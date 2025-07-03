// widgets/interactive_route_map.dart
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/coordinate.dart';
import '../../models/labeled_waypoint.dart';
import '../../models/legend_entry.dart';
import '../../view_models/route_viewmodel.dart';
import 'route_legend.dart'; // bring in the legend widget

class InteractiveRouteMap extends StatefulWidget {
  final bool draggable;
  final List<LabeledWaypoint>? initialWaypoints;
  final bool showLegend;

  const InteractiveRouteMap({
    Key? key,
    this.draggable = true,
    this.initialWaypoints,
    this.showLegend = true, // default to showing it
  }) : super(key: key);

  @override
  InteractiveRouteMapState createState() => InteractiveRouteMapState();
}

class InteractiveRouteMapState extends State<InteractiveRouteMap> {
  late final MapboxMap _map;
  late final CircleAnnotationManager _markerMgr;
  late final PolylineAnnotationManager _lineMgr;

  final List<CircleAnnotation> _markers = [];
  List<int> _pointColors = [];
  final List<PolylineAnnotation> _lines = [];
  List<LabeledWaypoint> _waypoints = [];

  Future<void> setWaypoints(List<LabeledWaypoint> wpts) async {
    setState(() {
      _waypoints = wpts;
    });

    final colorMap = _generateColorMapForLabels();
    _pointColors = _waypoints.map((w) => colorMap[w.label]!).toList();

    await _clearMarkers();
    for (var i = 0; i < wpts.length; i++) {
      final c = wpts[i].coord;
      final marker = await _markerMgr.create(
        _circleOpts(c.lon, c.lat, colorMap[wpts[i].label]!),
      );
      _markers.add(marker);
    }

    await _updateRoute();
    await _fitCamera();
  }

  Future<void> setCoordinates(List<Coordinate> coords) => setWaypoints(
        coords.map((c) => LabeledWaypoint(coord: c, label: "waypoint")).toList(),
      );

  static const List<Color> _predefinedColors = [
    Color(0xFF1E88E5), // Blue
    Color(0xFFD81B60), // Pink
    Color(0xFF43A047), // Green
    Color(0xFFF4511E), // Orange
    Color(0xFF8E24AA), // Purple
    Color(0xFF3949AB), // Indigo
    Color(0xFF00ACC1), // Teal
    Color(0xFF6D4C41), // Brown
    Color(0xFFEC407A), // Light Pink
    Color(0xFF26A69A), // Turquoise
    Color(0xFF5C6BC0), // Soft Blue
  ];

  Map<String, int> _generateColorMapForLabels() {
    final uniqueLabels = _waypoints.map((w) => w.label).toSet().toList();
    final colorMap = <String, int>{};

    for (var i = 0; i < uniqueLabels.length; i++) {
      final color = _predefinedColors[i % _predefinedColors.length];
      colorMap[uniqueLabels[i]] = color.toARGB32();
    }

    return colorMap;
  }

  CircleAnnotationOptions _circleOpts(double lon, double lat, int color) {
    return CircleAnnotationOptions(
      geometry: Point(coordinates: Position(lon, lat)),
      circleRadius: 8,
      circleColor: color,
      circleStrokeColor: 0xFFFFFFFF,
      circleStrokeWidth: 3,
      isDraggable: widget.draggable,
    );
  }

  Future<void> _clearMarkers() async {
    if (_markers.isNotEmpty) {
      await _markerMgr.deleteAll();
      _markers.clear();
      _pointColors.clear();
    }
  }

  Future<void> _updateRoute() async {
    final vm = context.read<RouteViewModel>();
    if (_markers.length >= 2) {
      final coords = _markers
          .map((m) => m.geometry.coordinates)
          .map((p) => Coordinate(p.lng.toDouble(), p.lat.toDouble()))
          .toList();
      await vm.fetchRoute(waypoints: coords);
      await _drawRoute(vm.route?.coords);
    } else {
      vm.clear();
      _clearRouteLine();
    }
  }

  Future<void> _drawRoute(List<List<Coordinate>>? routeLegs) async {
    if (routeLegs == null || routeLegs.isEmpty) return;
    _clearRouteLine();

    // Stack for tracking nested route segments
    List<int> colorStack = [];

    for (var i = 0; i < routeLegs.length; i++) {
      final coords = routeLegs[i];
      if (coords.isEmpty) continue;

      // Select color based on index or use default if out of range
      final color = i < _pointColors.length
          ? _pointColors[i]
          : _predefinedColors[0].toARGB32();

      // Parentheses-like behavior:
      // If we see a color that matches the top of stack, it's like a closing parenthesis - pop it
      // Otherwise, it's like an opening parenthesis - push it
      if (colorStack.isNotEmpty && colorStack.last == color) {
        // Found matching "closing parenthesis" - pop the stack
        colorStack.removeLast();
      } else {
        // New color - "opening parenthesis" - push to stack
        colorStack.add(color);
      }

      // Create route geometry
      final geometry = LineString(
        coordinates: coords.map((c) => Position(c.lon, c.lat)).toList(),
      );

      // Use the current depth for visualization
      // If stack is empty, use the current color; otherwise use stack top
      final displayColor = colorStack.isEmpty ? color : colorStack.last;
      final currentDepth = colorStack.length + (colorStack.isEmpty ? 1 : 0);

      // Draw the route segment
      final line = await _lineMgr.create(
        PolylineAnnotationOptions(
          geometry: geometry,
          lineColor: _predefinedColors[0].toARGB32(), // Use a fixed blue color for all route lines
          // Adjust line width based on nesting depth
          lineWidth: (8 - (currentDepth > 4 ? 4 : currentDepth - 1)).toDouble().clamp(1.0, 8.0),
          lineJoin: LineJoin.ROUND,
        ),
      );
      _lines.add(line);
    }
  }


  void _clearRouteLine() {
    for (final l in _lines) {
      _lineMgr.delete(l);
    }
    _lines.clear();
  }

  Future<void> _fitCamera() async {
    final vm = context.read<RouteViewModel>();
    final route = vm.route?.coords;
    if (route != null && route.length > 1) {
      final pts = route.expand((leg) => leg)
              .map((c) => Point(coordinates: Position(c.lon, c.lat)))
              .toList();
      final cam = await _map.cameraForCoordinatesPadding(
        pts,
        CameraOptions(),
        MbxEdgeInsets(top: 30, bottom: 40, left: 30, right: 30),
        null,
        null,
      );
      await _map.easeTo(cam, MapAnimationOptions(duration: 800));
    } else if (_markers.isNotEmpty) {
      final pts = _markers.map((m) => m.geometry).toList();
      final cam = await _map.cameraForCoordinatesPadding(
        pts,
        CameraOptions(),
        MbxEdgeInsets(top: 30, bottom: 30, left: 30, right: 30),
        null,
        null,
      );
      cam.zoom = (cam.zoom ?? 0) > 16 ? 16 : cam.zoom;
      await _map.easeTo(cam, MapAnimationOptions(duration: 800));
    }
  }

  void _onMapCreated(MapboxMap map) async {
    _map = map;
    _lineMgr =
        await _map.annotations.createPolylineAnnotationManager(id: 'routes');
    _markerMgr =
        await _map.annotations.createCircleAnnotationManager(id: 'waypoints');

    if (widget.draggable) {
      _markerMgr.dragEvents(onEnd: (CircleAnnotation a) async {
        final idx = _markers.indexWhere((m) => m.id == a.id);
        if (idx != -1) _markers[idx] = a;
        await _updateRoute();
        await _fitCamera();
      });
    }

    if (widget.initialWaypoints != null) {
      await setWaypoints(widget.initialWaypoints!);
    }
  }

  List<LegendEntry> _buildLegendItems() {
    final seen = <String>{};
    final items = <LegendEntry>[];

    for (var i = 0; i < _waypoints.length; i++) {
      final label = _waypoints[i].label;
      if (seen.add(label)) {
        items.add(
          LegendEntry(
            label: label,
            color: Color(_pointColors[i]),
          ),
        );
      }
    }

    debugPrint('Legend Entries: $items');
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final mapWidget = MapWidget(
      key: const ValueKey('mapWidget'),
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(30.8025, 26.8206)),
        zoom: 4.2,
      ),
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
    );

    if (!widget.showLegend) {
      return mapWidget;
    }

    return Stack(
      children: [
        mapWidget,
        RouteLegend(entries: _buildLegendItems()),
      ],
    );
  }
}
