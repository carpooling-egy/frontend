import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/ride_provider.dart';
import 'package:frontend/models/ride_offer.dart';
import 'package:frontend/ui/screens/activity_detail.dart';
import 'package:frontend/utils/date_time_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:frontend/ui/widgets/activity_card.dart';

class UpcomingTripsScreen extends StatelessWidget {
  const UpcomingTripsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Trips')),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          final offers = rideProvider.userRideOffers;
          final matchedRequests = rideProvider.userRideRequests.where((r) => r['matched'] == true).toList();

          if (offers.isEmpty && matchedRequests.isEmpty) {
            return const Center(child: Text('No upcoming trips.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (matchedRequests.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Matched as Rider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                ...matchedRequests.map((request) => ActivityCard(
                  type: ActivityCardType.matchedRider,
                  data: request,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailScreen(
                          activity: request,
                          type: 'request_matched',
                        ),
                      ),
                    );
                  },
                )),
              ],
              if (offers.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Your Offers as Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                ...offers.map((offer) => ActivityCard(
                  type: ActivityCardType.driverOffer,
                  data: offer,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailScreen(
                          activity: offer,
                          type: 'offer',
                        ),
                      ),
                    );
                  },
                )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MatchedRiderCard extends StatelessWidget {
  final Map<String, dynamic> request;
  const _MatchedRiderCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailScreen(
              activity: request,
              type: 'request_matched',
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text('Matched', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.person, color: Colors.deepOrange, size: 20),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('You as a rider', style: TextStyle(color: Color(0xFFD84315), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.2)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${request['pickupAddress']} → ${request['dropoffAddress']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, color: Colors.blue[700], size: 18),
                  const SizedBox(width: 4),
                  Text(request['driverName'] ?? '', style: TextStyle(color: Colors.blue[700], fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[600], size: 18),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDateTimeReadable(DateTime.parse(request['pickupTime'])),
                        style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        timeago.format(DateTime.parse(request['pickupTime']), allowFromNow: true),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverOfferCard extends StatelessWidget {
  final RideOffer offer;
  const _DriverOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final matchedRiders = offer.extra != null && offer.extra!['matchedRiders'] is List
        ? (offer.extra!['matchedRiders'] as List)
        : [];
    final remainingCapacity = offer.capacity - matchedRiders.length;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailScreen(
              activity: offer,
              type: 'offer',
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.black, size: 20),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Driver Offer', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.2)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${offer.sourceAddress} → ${offer.destinationAddress}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[600], size: 18),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDateTimeReadable(offer.departureTime),
                        style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        timeago.format(offer.departureTime, allowFromNow: true),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, color: Colors.grey[600], size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$remainingCapacity/${offer.capacity} seats left',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, color: Colors.grey[600], size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Matched: ${matchedRiders.length}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 