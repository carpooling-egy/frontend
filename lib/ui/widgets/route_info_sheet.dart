import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../view_models/route_info_viewmodel.dart';

class RouteInfoSheet extends StatelessWidget {
  const RouteInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteInfoViewModel>(
      builder: (_, vm, __) {
        if (vm.distance.isEmpty && vm.eta.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statTile('ETA', vm.eta),
              _statTile('Distance', vm.distance),
            ],
          ),
        );
      },
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
