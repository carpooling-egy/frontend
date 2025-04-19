import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/assets.dart';
import 'package:frontend/routing/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: HomeContent(),
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go(Routes.profile),
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(AppAssets.avatar),
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () {},
              ),
              const Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Welcome to Carpooling!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Choose an option below to get started:',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            HomeActionButton(
              icon: Icons.directions_car,
              label: 'Request a Ride',
              route: '/requestRide',
            ),
            HomeActionButton(
              icon: Icons.add_circle,
              label: 'Offer a Ride',
              route: '/offerRide',
            ),
          ],
        ),
        const SizedBox(height: 40),
        const Center(
          child: Text(
            'Explore carpooling options and make your journey easier!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}

class HomeActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const HomeActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.go(route),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
