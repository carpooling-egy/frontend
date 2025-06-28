import 'package:flutter/material.dart';
import '../../models/place_suggestion.dart';
import 'minimal_search_field.dart';

/// This widget contains two stacked MinimalSearchFields with icons:
/// - One for the source location
/// - One for the destination
///
/// The layout is minimalist, clean, and fully responsive.
class LocationSearchSection extends StatelessWidget {
  const LocationSearchSection({
    super.key,
    required this.onSourceSelected,
    required this.onDestinationSelected,
  });

  final ValueChanged<PlaceSuggestion> onSourceSelected;
  final ValueChanged<PlaceSuggestion> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MinimalSearchField(
          icon: Icons.my_location,
          hintText: 'Source Address',
          onSelected: onSourceSelected,
        ),
        const SizedBox(height: 12),
        MinimalSearchField(
          icon: Icons.flag,
          hintText: 'Destination Address',
          onSelected: onDestinationSelected,
        ),
      ],
    );
  }
}
