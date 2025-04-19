import 'package:flutter/material.dart';
import 'package:frontend/screens/shared/ride_screen.dart';

class OfferRideScreen extends StatelessWidget {
  const OfferRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RideScreen(
      title: 'Offer a Ride',
      message: 'This is the Offer a Ride screen.',
    );
  }
}
