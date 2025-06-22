import 'package:flutter/material.dart';
import 'package:frontend/routing/routes.dart';
import 'package:frontend/ui/widgets/custom_back_button.dart';
import 'package:frontend/utils/palette.dart';
import 'package:frontend/services/api/ride_service.dart';
import 'package:frontend/models/ride_request.dart';
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
  
  // Location controllers
  final TextEditingController _sourceAddressController = TextEditingController();
  final TextEditingController _destinationAddressController = TextEditingController();
  
  // Time controllers
  final TextEditingController _earliestDepartureTimeController = TextEditingController();
  final TextEditingController _latestArrivalTimeController = TextEditingController();
  
  // Other controllers
  final TextEditingController _maxWalkingTimeController = TextEditingController();
  final TextEditingController _numberOfRidersController = TextEditingController();
  
  // Preferences
  bool _sameGender = false;
  // Coordinates (to be set by geocoding)
  double _sourceLatitude = 42.5078;
  double _sourceLongitude = 1.5211;
  double _destinationLatitude = 42.5057;
  double _destinationLongitude = 1.5265;

  @override
  void dispose() {
    _sourceAddressController.dispose();
    _destinationAddressController.dispose();
    _earliestDepartureTimeController.dispose();
    _latestArrivalTimeController.dispose();
    _maxWalkingTimeController.dispose();
    _numberOfRidersController.dispose();
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

  Future<void> _selectDateTime(TextEditingController controller, bool isLatestArrival) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        
        if (isLatestArrival && _earliestDepartureTimeController.text.isNotEmpty) {
          final earliestTime = parseIso8601String(_earliestDepartureTimeController.text);
          if (dateTime.isBefore(earliestTime)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Latest arrival time must be after earliest departure time')),
            );
            return;
          }
        }
        
        controller.text = formatDateTimeToIso8601(dateTime);
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }
        final now = DateTime.now();
        final rideRequest = RideRequest(
          userId: currentUser.uid,
          sourceLatitude: _sourceLatitude,
          sourceLongitude: _sourceLongitude,
          sourceAddress: _sourceAddressController.text,
          destinationLatitude: _destinationLatitude,
          destinationLongitude: _destinationLongitude,
          destinationAddress: _destinationAddressController.text,
          earliestDepartureTime: parseIso8601String(_earliestDepartureTimeController.text),
          latestArrivalTime: parseIso8601String(_latestArrivalTimeController.text),
          maxWalkingTimeMinutes: int.parse(_maxWalkingTimeController.text),
          numberOfRiders: int.parse(_numberOfRidersController.text),
          sameGender: _sameGender,
          createdAt: now,
          updatedAt: now,
        );

        // Log the request data
        debugPrint('=== Ride Request Data ===');
        debugPrint('User ID: ${rideRequest.userId}');
        debugPrint('Source:');
        debugPrint('  Address: ${rideRequest.sourceAddress}');
        debugPrint('  Latitude: ${rideRequest.sourceLatitude}');
        debugPrint('  Longitude: ${rideRequest.sourceLongitude}');
        debugPrint('\nDestination:');
        debugPrint('  Address: ${rideRequest.destinationAddress}');
        debugPrint('  Latitude: ${rideRequest.destinationLatitude}');
        debugPrint('  Longitude: ${rideRequest.destinationLongitude}');
        debugPrint('\nTimes:');
        debugPrint('  Earliest Departure: ${formatDateTimeToIso8601(rideRequest.earliestDepartureTime)}');
        debugPrint('  Latest Arrival: ${formatDateTimeToIso8601(rideRequest.latestArrivalTime)}');
        debugPrint('\nDetails:');
        debugPrint('  Max Walking Time: ${rideRequest.maxWalkingTimeMinutes} minutes');
        debugPrint('  Number of Riders: ${rideRequest.numberOfRiders}');
        debugPrint('\nPreferences:');
        debugPrint('  Same Gender Only: ${rideRequest.sameGender}');
        debugPrint('\nJSON Payload:');
        debugPrint(JsonEncoder.withIndent('  ').convert(rideRequest.toJson()));
        debugPrint('===========================');

        await _rideService.requestRide(
          sourceLatitude: rideRequest.sourceLatitude,
          sourceLongitude: rideRequest.sourceLongitude,
          sourceAddress: rideRequest.sourceAddress,
          destinationLatitude: rideRequest.destinationLatitude,
          destinationLongitude: rideRequest.destinationLongitude,
          destinationAddress: rideRequest.destinationAddress,
          earliestDepartureTime: rideRequest.earliestDepartureTime,
          latestArrivalTime: rideRequest.latestArrivalTime,
          maxWalkingTimeMinutes: rideRequest.maxWalkingTimeMinutes,
          numberOfRiders: rideRequest.numberOfRiders,
          sameGender: rideRequest.sameGender,
          userId: rideRequest.userId,
          createdAt: rideRequest.createdAt,
          updatedAt: rideRequest.updatedAt,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ride request submitted successfully!')),
          );
          context.go(Routes.home);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(color: Palette.primaryColor, route: Routes.home),
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
                      // Source Location
                      TextFormField(
                        controller: _sourceAddressController,
                        decoration: _inputDecoration('Source Address'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter source address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Destination Location
                      TextFormField(
                        controller: _destinationAddressController,
                        decoration: _inputDecoration('Destination Address'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter destination address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Earliest Departure Time
                      TextFormField(
                        controller: _earliestDepartureTimeController,
                        decoration: _inputDecoration('Earliest Departure Time'),
                        readOnly: true,
                        onTap: () => _selectDateTime(_earliestDepartureTimeController, false),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select earliest departure time';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Latest Arrival Time
                      TextFormField(
                        controller: _latestArrivalTimeController,
                        decoration: _inputDecoration('Latest Arrival Time'),
                        readOnly: true,
                        onTap: () => _selectDateTime(_latestArrivalTimeController, true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select latest arrival time';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Max Walking Time
                      TextFormField(
                        controller: _maxWalkingTimeController,
                        decoration: _inputDecoration('Maximum Walking Time (minutes)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter maximum walking time';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Number of Riders
                      TextFormField(
                        controller: _numberOfRidersController,
                        decoration: _inputDecoration('Number of Riders'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of riders';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Preferences Section
                      const Text(
                        'Preferences',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Same Gender Switch
                      SwitchListTile(
                        title: const Text('Same Gender Only'),
                        value: _sameGender,
                        onChanged: (value) => setState(() => _sameGender = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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