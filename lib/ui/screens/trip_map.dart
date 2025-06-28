import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/coordinate.dart';
import '../../models/labeled_waypoint.dart';
import '../../view_models/route_info_viewmodel.dart';
import '../widgets/interactive_route_map.dart';
import '../widgets/route_info_sheet.dart';

/// A generic trip-preview screen.
///
/// * Use [TripScreen.rider] for a rider (pickup + drop-off only).
/// * Use [TripScreen.driver] for a driver (full ordered list of way-points).
class TripMapScreen extends StatefulWidget {
  final List<LabeledWaypoint> waypoints;
  final bool showLegend;

  const TripMapScreen({
    Key? key,
    required this.waypoints,
    this.showLegend = true,
  }) : super(key: key);

  factory TripMapScreen.rider({
    required Coordinate pickup,
    required Coordinate dropoff,
    required String riderName,
    bool showLegend = true,
  }) =>
      TripMapScreen(
        waypoints: [
          LabeledWaypoint(label: riderName, coord: pickup),
          LabeledWaypoint(label: riderName, coord: dropoff),
        ],
        showLegend: showLegend, // Pass it through
      );

  factory TripMapScreen.driver({
    required List<LabeledWaypoint> fullPath,
    bool showLegend = true, // Add to factory constructor
  }) => TripMapScreen(
    waypoints: fullPath,
    showLegend: showLegend, // Pass it through
  );

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  final _mapKey = GlobalKey<InteractiveRouteMapState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteInfoViewModel>().clear();
      _mapKey.currentState?.setWaypoints(widget.waypoints);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InteractiveRouteMap(
            key: _mapKey,
            draggable: false,
            initialWaypoints: widget.waypoints,
            showLegend: widget.showLegend,
          ),

          // Floating back button
          Positioned(
            top: 40,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => context.pop(),
              backgroundColor: Colors.white,
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),

          // Route info sheet at bottom
          const Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: RouteInfoSheet(),
          ),
        ],
      ),
    );
  }
}
