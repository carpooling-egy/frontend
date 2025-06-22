import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/api/ride_service.dart';
import 'package:frontend/utils/date_time_utils.dart';

class OfferRideScreen extends StatefulWidget {
  const OfferRideScreen({Key? key}) : super(key: key);

  @override
  _OfferRideScreenState createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceAddressController = TextEditingController();
  final _destinationAddressController = TextEditingController();
  final _detourTimeController = TextEditingController();
  final _capacityController = TextEditingController();

  double? _sourceLatitude;
  double? _sourceLongitude;
  double? _destinationLatitude;
  double? _destinationLongitude;
  DateTime? _departureTime;
  DateTime? _maxEstimatedArrivalTime;
  bool _sameGender = false;

  @override
  void dispose() {
    _sourceAddressController.dispose();
    _destinationAddressController.dispose();
    _detourTimeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final rideService = Provider.of<RideService>(context, listen: false);
      await rideService.offerRide(
        sourceLatitude: _sourceLatitude!,
        sourceLongitude: _sourceLongitude!,
        sourceAddress: _sourceAddressController.text,
        destinationLatitude: _destinationLatitude!,
        destinationLongitude: _destinationLongitude!,
        destinationAddress: _destinationAddressController.text,
        departureTime: _departureTime!,
        maxEstimatedArrivalTime: _maxEstimatedArrivalTime!,
        detourTimeMinutes: int.parse(_detourTimeController.text),
        capacity: int.parse(_capacityController.text),
        sameGender: _sameGender,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride offer created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating ride offer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer a Ride'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Source Location
              TextFormField(
                controller: _sourceAddressController,
                decoration: const InputDecoration(
                  labelText: 'Source Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter source address';
                  }
                  return null;
                },
                onChanged: (value) {
                  // TODO: Implement geocoding to get latitude and longitude
                  // For now, using dummy values
                  setState(() {
                    _sourceLatitude = 42.5078;
                    _sourceLongitude = 1.5211;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Destination Location
              TextFormField(
                controller: _destinationAddressController,
                decoration: const InputDecoration(
                  labelText: 'Destination Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter destination address';
                  }
                  return null;
                },
                onChanged: (value) {
                  // TODO: Implement geocoding to get latitude and longitude
                  // For now, using dummy values
                  setState(() {
                    _destinationLatitude = 42.5057;
                    _destinationLongitude = 1.5265;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Departure Time
              ListTile(
                title: const Text('Departure Time'),
                subtitle: Text(_departureTime != null ? formatDateTimeToIso8601(_departureTime!) : 'Not set'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _departureTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                        // Set max estimated arrival time to 1 hour after departure
                        _maxEstimatedArrivalTime = _departureTime!.add(
                          const Duration(hours: 1),
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // Max Estimated Arrival Time
              ListTile(
                title: const Text('Max Estimated Arrival Time'),
                subtitle: Text(_maxEstimatedArrivalTime != null ? formatDateTimeToIso8601(_maxEstimatedArrivalTime!) : 'Not set'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _departureTime ?? DateTime.now(),
                    firstDate: _departureTime ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _maxEstimatedArrivalTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // Detour Time
              TextFormField(
                controller: _detourTimeController,
                decoration: const InputDecoration(
                  labelText: 'Detour Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter detour time';
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
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter capacity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Preferences
              SwitchListTile(
                title: const Text('Same Gender Only'),
                value: _sameGender,
                onChanged: (value) {
                  setState(() => _sameGender = value);
                },
              ),
              
              const SizedBox(height: 24),
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Offer Ride'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 