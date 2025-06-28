import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'package:frontend/services/auth/firebase_auth_methods.dart';
import 'package:frontend/routing/routes.dart';
import 'package:frontend/services/profile_image_service.dart';
import 'package:frontend/providers/profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:frontend/config/assets.dart';
import 'package:frontend/utils/palette.dart';
import 'package:frontend/providers/ride_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:frontend/models/ride_offer.dart';
import 'package:frontend/ui/widgets/custom_back_button.dart';
import 'package:frontend/ui/screens/activity_detail.dart';
import 'package:frontend/utils/date_time_utils.dart';
import 'package:frontend/ui/screens/upcoming_trips.dart';
import 'package:frontend/ui/screens/pending_requests.dart';
import 'package:frontend/ui/widgets/activity_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProfileImageService _imageService = ProfileImageService();
  String? _profileImagePath;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
      final user = _auth.currentUser;
      if (user != null) {
        context.read<RideProvider>().loadSummarizedCards(user.uid);
      }
    });
  }

  Future<void> _loadProfileData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await context.read<ProfileProvider>().fetchProfile(user.uid);
    }
  }

  Future<void> _loadProfileImage() async {
    final savedImagePath = await _imageService.getSavedImagePath();
    if (savedImagePath != null) {
      setState(() {
        _profileImagePath = savedImagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final user = _auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '3al Sekka',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.black),
                  onPressed: () => context.go(Routes.notifications),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Palette.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : const AssetImage(AppAssets.avatar) as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome, ${profile?.firstName ?? 'User'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                context.go(Routes.home);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                context.go(Routes.profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.car_rental),
              title: const Text('Request a Ride'),
              onTap: () {
                Navigator.pop(context);
                context.go(Routes.requestRide);
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Offer a Ride'),
              onTap: () {
                Navigator.pop(context);
                context.go(Routes.offerRide);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text('Upcoming Trips'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UpcomingTripsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.hourglass_top),
              title: const Text('Pending Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PendingRequestsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                context.read<FirebaseAuthMethods>().signOut(context);
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await Future.wait([
              context.read<RideProvider>().loadSummarizedCards(user.uid),
              context.read<ProfileProvider>().fetchProfile(user.uid),
            ]);
            await _loadProfileImage();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Palette.primaryColor.withOpacity(0.8),
                      Palette.primaryColor,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const Text(
                      '3al Sekka',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Find your perfect ride match',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.car_rental,
                            title: 'Request',
                            subtitle: 'Find a ride',
                            color: Palette.orange,
                            onTap: () => context.go(Routes.requestRide),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.directions_car,
                            title: 'Offer',
                            subtitle: 'Share your ride',
                            color: Palette.primaryColor,
                            onTap: () => context.go(Routes.offerRide),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent Activity Section
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        if (rideProvider.isLoadingSummarized) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          );
        }

        if (rideProvider.error != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
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
                ),
              ],
            ),
          );
        }

        final cards = rideProvider.summarizedCards;

        if (cards.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No recent activities',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Start by requesting or offering a ride',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ...cards.map((card) => _buildSummarizedCard(context, card)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummarizedCard(BuildContext context, Map<String, dynamic> card) {
    print('\n\n\n\n');
    card.forEach((key, value) {
      print('key: $key, value: $value');
    });


    ActivityCardType type;
    if (card['type'].toString().contains('driver')) {
      type = ActivityCardType.driverOffer;
    // } else if (card['type'].toString().contains('rider') && card['matched']) {
      // type = ActivityCardType.matchedRider;
    } else if (card['type'].toString().contains('matchedRiderRequests') && card['matched']) {
      type = ActivityCardType.matchedRider;
    } else {
      type = ActivityCardType.unmatchedRider;
    }
    return ActivityCard(
      type: type,
      data: card,
      onTap: () async {
        final user = _auth.currentUser;
        if (user == null) return;
        final provider = context.read<RideProvider>();
        await provider.loadDetailedCard(
          type: card['type'].toString().replaceAll('-', '_'),
          userId: user.uid,
          cardId: card['id'].toString(),
        );
        if (provider.detailedCard != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityDetailScreen(
                activity: provider.detailedCard!,
                type: type == ActivityCardType.driverOffer
                    ? 'offer'
                    : (type == ActivityCardType.matchedRider ? 'request_matched' : 'request_unmatched'),
              ),
            ),
          );
        }
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}