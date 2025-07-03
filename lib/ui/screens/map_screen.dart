import 'package:flutter/material.dart';
import '../../models/coordinate.dart';
import '../../models/labeled_waypoint.dart';
import '../../models/map_pick_result.dart';
import '../../models/place_suggestion.dart';
import '../../view_models/route_info_viewmodel.dart';
import '../widgets/interactive_route_map.dart';
import '../widgets/location_search_section.dart';
import '../widgets/route_info_sheet.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey<InteractiveRouteMapState> _mapKey =
  GlobalKey<InteractiveRouteMapState>();

  PlaceSuggestion? _sourceSuggestion;
  PlaceSuggestion? _destinationSuggestion;

  Coordinate? get _sourceCoord =>
      _sourceSuggestion == null
          ? null
          : Coordinate(_sourceSuggestion!.lon, _sourceSuggestion!.lat);

  Coordinate? get _destinationCoord =>
      _destinationSuggestion == null
          ? null
          : Coordinate(_destinationSuggestion!.lon, _destinationSuggestion!.lat);

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      context.read<RouteInfoViewModel>().clear();
      _initialized = true;
    }
  }

  Future<void> _onSourceSelected(PlaceSuggestion s) async {
    setState(() {
      _sourceSuggestion = s;
    });
    await _updateRoute();
  }

  Future<void> _onDestSelected(PlaceSuggestion s) async {
    setState(() {
      _destinationSuggestion = s;
    });
    await _updateRoute();
  }

  // Future<void> _updateRoute() async {
  //   final waypoints = <LabeledWaypoint>[];
  //   if (_sourceCoord != null && _sourceSuggestion != null) {
  //     waypoints.add(LabeledWaypoint(
  //       coord: _sourceCoord!,
  //       label: "Source: ${_sourceSuggestion!.name}",
  //     ));
  //   }
  //   if (_destinationCoord != null && _destinationSuggestion != null) {
  //     waypoints.add(LabeledWaypoint(
  //       coord: _destinationCoord!,
  //       label: "Destination: ${_destinationSuggestion!.name}",
  //     ));
  //   }
  //   await _mapKey.currentState?.setWaypoints(waypoints);
  // }

  Future<void> _updateRoute() async {
    final points = <Coordinate>[];
    if (_sourceCoord != null) points.add(_sourceCoord!);
    if (_destinationCoord != null) points.add(_destinationCoord!);
    await _mapKey.currentState?.setCoordinates(points);
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _sourceSuggestion != null && _destinationSuggestion != null;

    return Scaffold(
      body: Stack(
        children: [
          InteractiveRouteMap(
            key: _mapKey,
            draggable: true,
            showLegend: false,
          ),

          // Floating search card
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: LocationSearchSection(
                onSourceSelected: _onSourceSelected,
                onDestinationSelected: _onDestSelected,
              ),
            ),
          ),

          // Confirm FAB
          Positioned(
            bottom: 140,
            right: 32,
            child: Visibility(
              visible: canConfirm,
              child: Tooltip(
                message: 'Confirm Route',
                child: FloatingActionButton(
                  onPressed: canConfirm
                      ? () {
                    Navigator.of(context).pop(
                      MapPickResult(
                        source: _sourceSuggestion!,
                        destination: _destinationSuggestion!,
                      ),
                    );
                  }
                      : null,
                  backgroundColor: Colors.indigo,
                  elevation: 4,
                  tooltip: 'Confirm Route',
                  child: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),

          // Route info sheet
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
