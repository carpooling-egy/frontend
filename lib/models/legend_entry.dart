import 'package:flutter/material.dart';

class LegendEntry {
  final String label;
  final Color color;
  LegendEntry({required this.label, required this.color});

  @override
  String toString() {
    return 'LegendEntry(label: $label, color: $color)';
  }
}