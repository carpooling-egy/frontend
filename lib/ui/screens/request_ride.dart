import 'package:flutter/material.dart';
import 'package:frontend/routing/routes.dart';
import 'package:frontend/ui/widgets/custom_back_button.dart';
import 'package:frontend/utils/palette.dart';
import 'package:frontend/services/api/ride_service.dart';
import 'package:frontend/models/ride_request.dart';
import 'package:frontend/models/map_pick_result.dart';
import 'package:frontend/models/place_suggestion.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/api/api_service.dart';
import 'package:frontend/services/auth/firebase_auth_methods.dart';
import 'package:frontend/utils/date_time_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  final _formKey = GlobalKey<FormState>();
  late final RideService _rideService;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final authMethods = context.read<FirebaseAuthMethods>();
    final apiService = ApiService(http.Client(), authMethods);
    _rideService = RideService(apiService);
  }

  // Picked places
  PlaceSuggestion? _sourceSuggestion;
  PlaceSuggestion? _destSuggestion;

  // Time controllers
  final TextEditingController _earliestDepartureController = TextEditingController();
  final TextEditingController _latestArrivalController = TextEditingController();

  // Other controllers
  final TextEditingController _maxWalkingController = TextEditingController();
  final TextEditingController _ridersController = TextEditingController();

  final TextEditingController _sourceAddressController = TextEditingController();
  final TextEditingController _destinationAddressController = TextEditingController();


  // Preferences
  bool _sameGender = false;

  @override
  void dispose() {
    _sourceAddressController.dispose();
    _destinationAddressController.dispose();
    _earliestDepartureController.dispose();
    _latestArrivalController.dispose();
    _maxWalkingController.dispose();
    _ridersController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    hintText: label,
    hintStyle: const TextStyle(color: Colors.grey),
    labelStyle: const TextStyle(color: Colors.black54),
    fillColor: Palette.lightGray,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );

  /* ─────────────────────────  Date/Time picker ───────────────────────── */
  Future<void> _selectDateTime(
      TextEditingController controller, {
        required bool isLatest,
      }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dt =
    DateTime(date.year, date.month, date.day, time.hour, time.minute);

    if (isLatest && _earliestDepartureController.text.isNotEmpty) {
      final earliest = parseIso8601String(_earliestDepartureController.text);
      if (dt.isBefore(earliest)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Latest arrival must be after earliest departure'),
          ),
        );
        return;
      }
    }

    controller.text = formatDateTimeToIso8601(dt);
  }

  /* ─────────────────────────  Map picker ───────────────────────── */
  Future<void> _pickLocations() async {
    final result = await GoRouter.of(context).push<MapPickResult>(Routes.map);
    if (result == null) return;

    setState(() {
      _sourceSuggestion = result.source;
      _destSuggestion = result.destination;

      _sourceAddressController.text = result.source.label;
      _destinationAddressController.text = result.destination.label;
    });
  }

  /* ─────────────────────────  Submit ───────────────────────── */
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sourceSuggestion == null || _destSuggestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick source & destination')),
      );
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Not authenticated');
      final now = DateTime.now();

      final req = RideRequest(
        userId: user.uid,
        sourceLatitude: _sourceSuggestion!.lat,
        sourceLongitude: _sourceSuggestion!.lon,
        sourceAddress: _sourceSuggestion!.label,
        destinationLatitude: _destSuggestion!.lat,
        destinationLongitude: _destSuggestion!.lon,
        destinationAddress: _destSuggestion!.label,
        earliestDepartureTime:
        parseIso8601String(_earliestDepartureController.text),
        latestArrivalTime: parseIso8601String(_latestArrivalController.text),
        maxWalkingTimeMinutes: int.parse(_maxWalkingController.text),
        numberOfRiders: int.parse(_ridersController.text),
        sameGender: _sameGender,
        createdAt: now,
        updatedAt: now,
      );

      await _rideService.requestRide(
        sourceLatitude: req.sourceLatitude,
        sourceLongitude: req.sourceLongitude,
        sourceAddress: req.sourceAddress,
        destinationLatitude: req.destinationLatitude,
        destinationLongitude: req.destinationLongitude,
        destinationAddress: req.destinationAddress,
        earliestDepartureTime: req.earliestDepartureTime,
        latestArrivalTime: req.latestArrivalTime,
        maxWalkingTimeMinutes: req.maxWalkingTimeMinutes,
        numberOfRiders: req.numberOfRiders,
        sameGender: req.sameGender,
        userId: req.userId,
        createdAt: req.createdAt,
        updatedAt: req.updatedAt,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride request sent!')),
        );
        context.go(Routes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /* ─────────────────────────  UI ───────────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
        const CustomBackButton(color: Palette.primaryColor, route: Routes.home),
        title: const Text('Request a Ride'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ───────── Source ─────────
                      TextFormField(
                        readOnly: true,
                        decoration: _inputDecoration('Source Address'),
                        controller: _sourceAddressController,
                        onTap: _pickLocations,
                        validator: (_) => _sourceSuggestion == null ? 'Select source' : null,
                      ),
                      const SizedBox(height: 16),

                      // ───────── Destination ─────────
                      TextFormField(
                        readOnly: true,
                        decoration: _inputDecoration('Destination Address'),
                        controller: _destinationAddressController,
                        onTap: _pickLocations,
                        validator: (_) => _destSuggestion == null ? 'Select destination' : null,
                      ),

                      const SizedBox(height: 16),

                      /* ───────── Earliest departure ───────── */
                      TextFormField(
                        controller: _earliestDepartureController,
                        decoration:
                        _inputDecoration('Earliest Departure Time'),
                        readOnly: true,
                        onTap: () => _selectDateTime(
                          _earliestDepartureController,
                          isLatest: false,
                        ),
                        validator: (v) =>
                        v == null || v.isEmpty ? 'Select time' : null,
                      ),
                      const SizedBox(height: 16),

                      /* ───────── Latest arrival ───────── */
                      TextFormField(
                        controller: _latestArrivalController,
                        decoration: _inputDecoration('Latest Arrival Time'),
                        readOnly: true,
                        onTap: () => _selectDateTime(
                          _latestArrivalController,
                          isLatest: true,
                        ),
                        validator: (v) =>
                        v == null || v.isEmpty ? 'Select time' : null,
                      ),
                      const SizedBox(height: 16),

                      /* ───────── Max walking ───────── */
                      TextFormField(
                        controller: _maxWalkingController,
                        decoration: _inputDecoration(
                          'Maximum Walking Time (minutes)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Enter walking time';
                          }
                          if (int.tryParse(v) == null) {
                            return 'Enter a number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      /* ───────── Riders ───────── */
                      TextFormField(
                        controller: _ridersController,
                        decoration: _inputDecoration('Number of Riders'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Enter riders';
                          }
                          if (int.tryParse(v) == null) {
                            return 'Enter a number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Preferences',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      SwitchListTile(
                        title: const Text('Same Gender Only'),
                        value: _sameGender,
                        onChanged: (val) => setState(() => _sameGender = val),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /* ───────── Submit button ───────── */
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Request Ride',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
