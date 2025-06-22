import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/ride_provider.dart';
import 'package:frontend/ui/screens/activity_detail.dart';
import 'package:frontend/utils/date_time_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:frontend/ui/widgets/activity_card.dart';

class PendingRequestsScreen extends StatelessWidget {
  const PendingRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Requests')),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          final unmatchedRequests = rideProvider.userRideRequests.where((r) => r['matched'] == false).toList();

          if (unmatchedRequests.isEmpty) {
            return const Center(child: Text('No pending requests.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...unmatchedRequests.map((request) => ActivityCard(
                type: ActivityCardType.unmatchedRider,
                data: request,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityDetailScreen(
                        activity: request,
                        type: 'request_unmatched',
                      ),
                    ),
                  );
                },
              )),
            ],
          );
        },
      ),
    );
  }
}

class _UnmatchedRiderCard extends StatelessWidget {
  final Map<String, dynamic> request;
  const _UnmatchedRiderCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailScreen(
              activity: request,
              type: 'request_unmatched',
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Person icon + label
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
                    child: const Text(
                      'You as a rider',
                      style: TextStyle(
                        color: Color(0xFFD84315),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Main Info: Source → Destination
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${request['sourceAddress']} → ${request['destinationAddress']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Earliest departure time
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
              // Not matched yet tag
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
                        Text(
                          'Not matched yet',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
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
} 