import 'package:flutter/material.dart';
import 'package:frontend/models/ride_offer.dart';
import 'package:frontend/models/coordinate.dart';
import 'package:frontend/ui/screens/trip_map.dart'; // kept
import 'package:frontend/utils/date_time_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';

import '../../models/labeled_waypoint.dart';
import '../../routing/routes.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Map<String, dynamic> activity;
  final String type; // 'offer', 'request_matched', 'request_unmatched'

  const ActivityDetailScreen({
    Key? key,
    required this.activity,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildDetails(context),
      ),
    );
  }


  List<LabeledWaypoint> _buildDriverWaypoints(Map<String, dynamic> offer) {
    final rawPath = offer['path'] as List<dynamic>? ?? <dynamic>[];
    final matchedRiders = (offer['matchedRiders'] as List<Map<String, dynamic>>?)
        ?? <Map<String, dynamic>>[];

    final fullPathWaypoints = <LabeledWaypoint>[];

    fullPathWaypoints.add(
      LabeledWaypoint(
        coord: Coordinate(
          offer['sourceLongitude'],
          offer['sourceLatitude'],
        ),
        label: 'You',
      ),
    );

    for (int i = 0; i < rawPath.length; i++) {
      final pt = rawPath[i] as Map<String, dynamic>;
      final riderName = '${matchedRiders[i]['riderFirstName'] ?? ''} ${matchedRiders[i]['riderLastName'] ?? ''}';
      final lat =
          (pt['latitude'] is num) ? (pt['latitude'] as num).toDouble() : 0.0;
      final lon =
          (pt['longitude'] is num) ? (pt['longitude'] as num).toDouble() : 0.0;

      fullPathWaypoints.add(
        LabeledWaypoint(
          coord: Coordinate(lon, lat),
          label: riderName,
        ),
      );
    }

    fullPathWaypoints.add(
      LabeledWaypoint(
        coord: Coordinate(
          offer['destinationLongitude'],
          offer['destinationLatitude'],
        ),
        label: 'You',
      ),
    );

    return fullPathWaypoints;
  }

  Widget _buildDetails(BuildContext context) {

    if (type == 'offer') {
      final offer = activity;
      final matchedRiders = offer['matchedRiders'] is List ? offer['matchedRiders'] as List : [];

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------- HEADER ------------------------------------------------
            Row(
              children: [
                Icon(Icons.directions_car, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'You as a driver',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ------------- SOURCE / DESTINATION ----------------------------------
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(child: Text('From: ${offer['sourceAddress'] ?? '-'}', style: const TextStyle(fontSize: 16))),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(child: Text('To: ${offer['destinationAddress'] ?? '-'}', style: const TextStyle(fontSize: 16))),
              ],
            ),
            const SizedBox(height: 10),
            // ------------- DEPARTURE --------------------------------------------
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Departure: ${formatDateTimeReadable(DateTime.tryParse(offer['departureTime'] ?? offer['createdAt'] ?? '') ?? DateTime.now())}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    Text(timeago.format(DateTime.tryParse(offer['departureTime'] ?? offer['createdAt'] ?? '') ?? DateTime.now() as DateTime, allowFromNow: true), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ------------- CAPACITY ---------------------------------------------
            Row(
              children: [
                const Icon(Icons.event_seat, color: Colors.purple),
                const SizedBox(width: 6),
                Text('Capacity: ${offer['capacity'] ?? '-'}', style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 24),
            // ------------- MATCHED RIDERS ----------------------------------------
            const Text('Matched Riders',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 10),
            if (matchedRiders.isNotEmpty)
              ...matchedRiders.map<Widget>((rider) => Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blueGrey),
                          const SizedBox(width: 6),
                          Text('Name: ${rider['riderFirstName'] ?? rider['riderName'] ?? ''} ${rider['riderLastName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          Icon(
                            (rider['riderGender']?.toString().toLowerCase() == 'male') ? Icons.male : Icons.female,
                            color: (rider['riderGender']?.toString().toLowerCase() == 'male') ? Colors.blue : Colors.pink,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.green, size: 18),
                          const SizedBox(width: 4),
                          Expanded(child: Text('Pickup: ${rider['pickupAddress'] ?? '-'}', style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('at ${formatDateTimeReadable(DateTime.tryParse(rider['pickupTime'] ?? '') ?? DateTime.now())}', style: const TextStyle(fontSize: 14)),
                              Text(rider['pickupTime'] != null ? timeago.format(DateTime.tryParse(rider['pickupTime']) ?? DateTime.now() as DateTime, allowFromNow: true) : '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.flag, color: Colors.red, size: 18),
                          const SizedBox(width: 4),
                          Expanded(child: Text('Dropoff: ${rider['dropoffAddress'] ?? '-'}', style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('at ${formatDateTimeReadable(DateTime.tryParse(rider['dropoffTime'] ?? '') ?? DateTime.now())}', style: const TextStyle(fontSize: 14)),
                              Text(rider['dropoffTime'] != null ? timeago.format(DateTime.tryParse(rider['dropoffTime']) ?? DateTime.now() as DateTime, allowFromNow: true) : '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ))
            else
              const Text('No matched riders yet.'),
            // ------------- SHOW PATH BUTTON --------------------------------------
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  Routes.tripMap,
                  extra: TripMapScreen.driver(
                      fullPath: _buildDriverWaypoints(offer)),
                ), // GoRouter navigation
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text('Show path on the map',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  backgroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (type == 'request_matched') {
      final req = activity;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Matched',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.person, color: Colors.deepOrange),
                const SizedBox(width: 8),
                const Text('You as a rider',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(child: Text('Pickup: ${req['pickupAddress'] ?? req['sourceAddress'] ?? '-'}', style: const TextStyle(fontSize: 16))),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(child: Text('Dropoff: ${req['dropoffAddress'] ?? req['destinationAddress'] ?? '-'}', style: const TextStyle(fontSize: 16))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pickup Time: ${formatDateTimeReadable(DateTime.tryParse(req['pickupTime'] ?? req['createdAt'] ?? req['tripDate'] ?? '') ?? DateTime.now())}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    Text(timeago.format(DateTime.tryParse(req['pickupTime'] ?? req['createdAt'] ?? req['tripDate'] ?? '') ?? DateTime.now() as DateTime, allowFromNow: true), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dropoff Time: ${formatDateTimeReadable(DateTime.tryParse(req['dropoffTime'] ?? '') ?? DateTime.now())}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    Text(timeago.format(DateTime.tryParse(req['dropoffTime'] ?? '') ?? DateTime.now() as DateTime, allowFromNow: true), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Driver Info',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 10),
            Card(
              margin: const EdgeInsets.only(bottom: 14),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(req['driverName'] ?? '${req['driverFirstName'] ?? ''} ${req['driverLastName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(width: 16),
                    Icon(
                      (req['driverGender']?.toString().toLowerCase() == 'male')
                          ? Icons.male
                          : Icons.female,
                      color: (req['driverGender']?.toString().toLowerCase() ==
                              'male')
                          ? Colors.blue
                          : Colors.pink,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  Routes.tripMap,
                  extra: TripMapScreen.rider(
                      pickup: Coordinate(
                          req['pickupLongitude'], req['pickupLatitude']),
                      dropoff: Coordinate(
                          req['dropoffLongitude'], req['dropoffLatitude']),
                      riderName: 'You',
                      showLegend: false),
                ),
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text('Show path on the map',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  backgroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (type == 'request_unmatched') {
      final req = activity;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.deepOrange),
                const SizedBox(width: 8),
                const Text('You as a rider',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(child: Text('From: ${req['sourceAddress'] ?? '-'}', style: const TextStyle(fontSize: 16))),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(child: Text('To: ${req['destinationAddress'] ?? '-'}', style: const TextStyle(fontSize: 16))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Earliest Departure: ${formatDateTimeReadable(DateTime.tryParse(req['earliestDepartureTime'] ?? req['createdAt'] ?? '') ?? DateTime.now())}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    Text(timeago.format(DateTime.tryParse(req['earliestDepartureTime'] ?? req['createdAt'] ?? '') ?? DateTime.now() as DateTime, allowFromNow: true), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latest Arrival: ${formatDateTimeReadable(DateTime.tryParse(req['latestArrivalTime'] ?? '') ?? DateTime.now())}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    Text(timeago.format(DateTime.tryParse(req['latestArrivalTime'] ?? '') ?? DateTime.now() as DateTime, allowFromNow: true), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.group, color: Colors.purple),
                const SizedBox(width: 6),
                Text('Number of Riders: ${req['numberOfRiders'] ?? '-'}', style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.directions_walk, color: Colors.teal),
                const SizedBox(width: 6),
                Text('Max Walking Time: ${req['maxWalkingTimeMinutes'] ?? '-'} min', style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.wc, color: Colors.indigo),
                const SizedBox(width: 6),
                Text(
                    'Same Gender Only: ${req['sameGender'] == true ? "Yes" : "No"}',
                    style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.hourglass_empty, color: Colors.red, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Not matched yet',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  Routes.tripMap,
                  extra: TripMapScreen.rider(
                    pickup: Coordinate(
                        req['sourceLongitude'], req['sourceLatitude']),
                    dropoff: Coordinate(req['destinationLongitude'],
                        req['destinationLatitude']),
                    riderName: 'You',
                    showLegend: false,
                  ),
                ), // GoRouter navigation
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text('Show path on the map',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  backgroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ──────────────────────────────────────────────────────────────────────────
    // FALLBACK
    // ──────────────────────────────────────────────────────────────────────────
    else {
      return const Text('Unknown activity type.');
    }
  }
}
