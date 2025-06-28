import 'package:flutter/material.dart';
import 'package:frontend/routing/routes.dart';
import 'package:frontend/ui/widgets/custom_back_button.dart';
import 'package:frontend/utils/palette.dart';
import 'package:frontend/services/api/ride_service.dart';
import 'package:frontend/models/ride_offer.dart';
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
  
  // Location controllers
  final TextEditingController _sourceAddressController = TextEditingController();
  final TextEditingController _destinationAddressController = TextEditingController();
  
  // Time controllers
  final TextEditingController _departureTimeController = TextEditingController();
  final TextEditingController _maxArrivalTimeController = TextEditingController();
  
  // Other controllers
  final TextEditingController _detourTimeController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  
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
        
        if (isMaxArrival && _departureTimeController.text.isNotEmpty) {
          final departureTime = DateTime.parse(_departureTimeController.text);
          if (dateTime.isBefore(departureTime)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Max arrival time must be after departure time')),
            );
            return;
          }
        }
        
        controller.text = dateTime.toIso8601String();
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
        final rideOffer = RideOffer(
          userId: currentUser.uid,
          sourceLatitude: _sourceLatitude,
          sourceLongitude: _sourceLongitude,
          sourceAddress: _sourceAddressController.text,
          destinationLatitude: _destinationLatitude,
          destinationLongitude: _destinationLongitude,
          destinationAddress: _destinationAddressController.text,
          departureTime: DateTime.parse(_departureTimeController.text),
          maxEstimatedArrivalTime: DateTime.parse(_maxArrivalTimeController.text),
          detourTimeMinutes: int.parse(_detourTimeController.text),
          capacity: int.parse(_capacityController.text),
          sameGender: _sameGender,
          createdAt: now,
          updatedAt: now,
        );

        // Log the request data
        debugPrint('=== Ride Offer Request Data ===');
        debugPrint('User ID: ${rideOffer.userId}');
        debugPrint('Source:');
        debugPrint('  Address: ${rideOffer.sourceAddress}');
        debugPrint('  Latitude: ${rideOffer.sourceLatitude}');
        debugPrint('  Longitude: ${rideOffer.sourceLongitude}');
        debugPrint('\nDestination:');
        debugPrint('  Address: ${rideOffer.destinationAddress}');
        debugPrint('  Latitude: ${rideOffer.destinationLatitude}');
        debugPrint('  Longitude: ${rideOffer.destinationLongitude}');
        debugPrint('\nTimes:');
        debugPrint('  Departure: ${rideOffer.departureTime.toIso8601String()}');
        debugPrint('  Max Arrival: ${rideOffer.maxEstimatedArrivalTime.toIso8601String()}');
        debugPrint('\nDetails:');
        debugPrint('  Detour Time: ${rideOffer.detourTimeMinutes} minutes');
        debugPrint('  Capacity: ${rideOffer.capacity} seats');
        debugPrint('\nPreferences:');
        debugPrint('  Same Gender Only: ${rideOffer.sameGender}');
        debugPrint('\nJSON Payload:');
        debugPrint(JsonEncoder.withIndent('  ').convert(rideOffer.toJson()));
        debugPrint('===========================');

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(color: Palette.primaryColor, route: Routes.home),
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
                      
                      // Departure Time
                      TextFormField(
                        controller: _departureTimeController,
                        decoration: _inputDecoration('Departure Time'),
                        readOnly: true,
                        onTap: () => _selectDateTime(_departureTimeController, false),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select departure time';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Max Arrival Time
                      TextFormField(
                        controller: _maxArrivalTimeController,
                        decoration: _inputDecoration('Maximum Arrival Time'),
                        readOnly: true,
                        onTap: () => _selectDateTime(_maxArrivalTimeController, true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select maximum arrival time';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Detour Time
                      TextFormField(
                        controller: _detourTimeController,
                        decoration: _inputDecoration('Maximum Detour Time (minutes)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter maximum detour time';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Capacity
                      TextFormField(
                        controller: _capacityController,
                        decoration: _inputDecoration('Available Seats'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of seats';
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
                      
                      const SizedBox(height: 24),
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