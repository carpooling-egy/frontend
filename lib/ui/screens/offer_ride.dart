import 'package:flutter/material.dart';
import 'package:frontend/routing/routes.dart';
import 'package:frontend/ui/widgets/custom_back_button.dart';
import 'package:frontend/utils/palette.dart';
import 'package:frontend/services/api/ride_service.dart';
import 'package:frontend/models/ride_offer.dart';
import 'package:frontend/models/map_pick_result.dart';
import 'package:frontend/models/place_suggestion.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/api/api_service.dart';
import 'package:frontend/services/auth/firebase_auth_methods.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/utils/show_snackbar.dart';

class OfferRideScreen extends StatefulWidget {
  const OfferRideScreen({super.key});

  @override
  State<OfferRideScreen> createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
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

  PlaceSuggestion? _sourceSuggestion;
  PlaceSuggestion? _destSuggestion;

  // Time controllers
  final TextEditingController _departureTimeController = TextEditingController();
  final TextEditingController _maxArrivalTimeController = TextEditingController();

  // Other controllers
  final TextEditingController _detourTimeController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  // Preferences
  bool _sameGender = false;

  @override
  void dispose() {
    _departureTimeController.dispose();
    _maxArrivalTimeController.dispose();
    _detourTimeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      fillColor: Palette.lightGray,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _selectDateTime(TextEditingController controller, bool isMaxArrival) async {
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

    final dt = DateTime(
        date.year, date.month, date.day, time.hour, time.minute
    );
    if (isMaxArrival && _departureTimeController.text.isNotEmpty) {
      final departure = DateTime.parse(_departureTimeController.text);
      if (dt.isBefore(departure)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Max arrival must be after departure')),
        );
        return;
      }
    }
    controller.text = dt.toIso8601String();
  }

  Future<void> _pickLocations() async {
    final result = await GoRouter.of(context).push<MapPickResult>(Routes.map);
    if (result == null) return;
    setState(() {
      _sourceSuggestion = result.source;
      _destSuggestion   = result.destination;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sourceSuggestion == null || _destSuggestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both source & destination')),
      );
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Not authenticated');
      final now = DateTime.now();


      final rideOffer = RideOffer(
        userId: user.uid,
        sourceLatitude: _sourceSuggestion!.lat,
        sourceLongitude: _sourceSuggestion!.lon,
        sourceAddress: _sourceSuggestion!.label,
        destinationLatitude: _destSuggestion!.lat,
        destinationLongitude: _destSuggestion!.lon,
        destinationAddress: _destSuggestion!.label,
        departureTime: DateTime.parse(_departureTimeController.text),
        maxEstimatedArrivalTime: DateTime.parse(_maxArrivalTimeController.text),
        detourTimeMinutes: int.parse(_detourTimeController.text),
        capacity: int.parse(_capacityController.text),
        sameGender: _sameGender,
        createdAt: now,
        updatedAt: now,
      );

      debugPrint('Offer JSON: ${jsonEncode(rideOffer.toJson())}');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _rideService.offerRide(
          sourceLatitude: rideOffer.sourceLatitude,
          sourceLongitude: rideOffer.sourceLongitude,
          sourceAddress: rideOffer.sourceAddress,
          destinationLatitude: rideOffer.destinationLatitude,
          destinationLongitude: rideOffer.destinationLongitude,
          destinationAddress: rideOffer.destinationAddress,
          departureTime: rideOffer.departureTime,
          maxEstimatedArrivalTime: rideOffer.maxEstimatedArrivalTime,
          detourTimeMinutes: rideOffer.detourTimeMinutes,
          capacity: rideOffer.capacity,
          sameGender: rideOffer.sameGender,
          userId: rideOffer.userId,
          createdAt: rideOffer.createdAt,
          updatedAt: rideOffer.updatedAt,
        );
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          showSnackBar(
            context,
            'Ride offer submitted successfully!',
            backgroundColor: Colors.green,
            icon: Icons.check_circle,
          );
          context.go(Routes.home);
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          String errorMessage = 'An error occurred. Please try again.';
          final errorStr = e.toString();
          final match = RegExp(r'\{.*\}').firstMatch(errorStr);
          if (match != null) {
            try {
              final Map<String, dynamic> errorJson = jsonDecode(match.group(0)!);
              if (errorJson['message'] != null) {
                errorMessage = errorJson['message'];
              }
            } catch (_) {}
          }
          showSnackBar(
            context,
            errorMessage,
            backgroundColor: Colors.red,
            icon: Icons.error,
          );
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(color: Palette.primaryColor, route: Routes.home),
        title: const Text('Offer a Ride'),
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
                      // Source Address field
                      TextFormField(
                        readOnly: true,
                        decoration: _inputDecoration('Source Address'),
                        controller: TextEditingController(
                          text: _sourceSuggestion?.label ?? '',
                        ),
                        onTap: _pickLocations,
                        validator: (_) =>
                        _sourceSuggestion == null ? 'Select source' : null,
                      ),
                      const SizedBox(height: 16),

                      // Destination Address field
                      TextFormField(
                        readOnly: true,
                        decoration: _inputDecoration('Destination Address'),
                        controller: TextEditingController(
                          text: _destSuggestion?.label ?? '',
                        ),
                        onTap: _pickLocations,
                        validator: (_) =>
                        _destSuggestion == null ? 'Select destination' : null,
                      ),
                      const SizedBox(height: 16),

                      // Departure Time
                      TextFormField(
                        controller: _departureTimeController,
                        decoration: _inputDecoration('Departure Time'),
                        readOnly: true,
                        onTap: () => _selectDateTime(_departureTimeController, false),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Select departure time' : null,
                      ),
                      const SizedBox(height: 16),

                      // Max Arrival Time
                      TextFormField(
                        controller: _maxArrivalTimeController,
                        decoration: _inputDecoration('Maximum Arrival Time'),
                        readOnly: true,
                        onTap: () => _selectDateTime(_maxArrivalTimeController, true),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Select max arrival time' : null,
                      ),
                      const SizedBox(height: 16),

                      // Detour Time
                      TextFormField(
                        controller: _detourTimeController,
                        decoration: _inputDecoration('Maximum Detour Time (minutes)'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter detour time';
                          if (int.tryParse(v) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Capacity
                      TextFormField(
                        controller: _capacityController,
                        decoration: _inputDecoration('Available Seats'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter seats';
                          if (int.tryParse(v) == null) return 'Enter a number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Preferences',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            // Submit button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Offer Ride',
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

