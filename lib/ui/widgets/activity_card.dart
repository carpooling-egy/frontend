import 'package:flutter/material.dart';
import 'package:frontend/models/ride_offer.dart';
import 'package:frontend/utils/date_time_utils.dart';
import 'package:frontend/utils/palette.dart';
import 'package:timeago/timeago.dart' as timeago;

enum ActivityCardType { matchedRider, unmatchedRider, driverOffer }

class ActivityCard extends StatelessWidget {
  final ActivityCardType type;
  final dynamic data;
  final VoidCallback? onTap;

  const ActivityCard({
    Key? key,
    required this.type,
    required this.data,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ActivityCardType.matchedRider:
        return _buildMatchedRiderCard(context);
      case ActivityCardType.unmatchedRider:
        return _buildUnmatchedRiderCard(context);
      case ActivityCardType.driverOffer:
        return _buildDriverOfferCard(context);
    }
  }

  Widget _buildMatchedRiderCard(BuildContext context) {
    final request = data as Map<String, dynamic>;
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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

  Widget _buildUnmatchedRiderCard(BuildContext context) {
    final request = data as Map<String, dynamic>;
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                      '${request['sourceAddress']} → ${request['destinationAddress']}',
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
                        formatDateTimeReadable(DateTime.parse(request['earliestDepartureTime'])),
                        style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        timeago.format(DateTime.parse(request['earliestDepartureTime']), allowFromNow: true),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.hourglass_empty, color: Colors.red, size: 16),
                        SizedBox(width: 4),
                        Text('Not matched yet', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverOfferCard(BuildContext context) {
    final offer = data as RideOffer;
    final matchedRiders = offer.extra != null && offer.extra!['matchedRiders'] is List
        ? (offer.extra!['matchedRiders'] as List)
        : [];
    final remainingCapacity = offer.capacity - matchedRiders.length;
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_car, color: Palette.primaryColor, size: 20),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('You as a driver', style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.2)),
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