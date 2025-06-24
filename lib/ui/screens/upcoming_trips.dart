import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/ride_provider.dart';
import 'package:frontend/ui/screens/activity_detail.dart';
import 'package:frontend/utils/date_time_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:frontend/ui/widgets/activity_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpcomingTripsScreen extends StatefulWidget {
  const UpcomingTripsScreen({Key? key}) : super(key: key);

  @override
  State<UpcomingTripsScreen> createState() => _UpcomingTripsScreenState();
}

class _UpcomingTripsScreenState extends State<UpcomingTripsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await context.read<RideProvider>().loadSummarizedCards(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Trips')),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          if (rideProvider.isLoadingSummarized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (rideProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Error loading activities',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Please try again later',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final matchedRequests = rideProvider.summarizedCards
              .where((card) => card['type'].toString().contains('matchedRiderRequests'))
              .toList();

          final driverOffers = rideProvider.summarizedCards
              .where((card) => card['type'].toString().contains('driverOffers'))
              .toList();

          if (matchedRequests.isEmpty && driverOffers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No upcoming trips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (matchedRequests.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Matched as Rider', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    )
                  ),
                ),
                ...matchedRequests.map((request) => ActivityCard(
                  type: ActivityCardType.matchedRider,
                  data: request,
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    
                    await rideProvider.loadDetailedCard(
                      type: request['type'].toString().replaceAll('-', '_'),
                      userId: user.uid,
                      cardId: request['id'].toString(),
                    );
                    
                    if (rideProvider.detailedCard != null) {
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityDetailScreen(
                            activity: rideProvider.detailedCard!,
                            type: 'request_matched',
                          ),
                        ),
                      );
                    }
                  },
                )),
              ],
              if (driverOffers.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Your Offers as Driver', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    )
                  ),
                ),
                ...driverOffers.map((offer) => ActivityCard(
                  type: ActivityCardType.driverOffer,
                  data: offer,
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    
                    await rideProvider.loadDetailedCard(
                      type: offer['type'].toString().replaceAll('-', '_'),
                      userId: user.uid,
                      cardId: offer['id'].toString(),
                    );
                    
                    if (rideProvider.detailedCard != null) {
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityDetailScreen(
                            activity: rideProvider.detailedCard!,
                            type: 'offer',
                          ),
                        ),
                      );
                    }
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