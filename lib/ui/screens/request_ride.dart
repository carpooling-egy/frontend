import 'package:flutter/material.dart';
import 'package:frontend/screens/shared/ride_screen.dart';

class RequestRideScreen extends StatelessWidget {
  const RequestRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RideScreen(
      title: 'Request a Ride',
      message: 'This is the Request a Ride screen.',
    );
  }
}
