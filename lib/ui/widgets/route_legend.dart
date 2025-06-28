import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/legend_entry.dart';

class RouteLegend extends StatefulWidget {
  final List<LegendEntry> entries;
  final double width;

  const RouteLegend({
    Key? key,
    required this.entries,
    this.width = 300,
  }) : super(key: key);

  @override
  _RouteLegendState createState() => _RouteLegendState();
}

class _RouteLegendState extends State<RouteLegend>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  bool _isOpen = false;

  static const double _toggleBottom = 140;
  static const double _toggleRight = 32;
  static const double _elevationFactor = 1.63;

  // Adjusted for exactly 3 items
  static const double _itemHeight = 24.0;
  static const double _containerPadding = 8.0;
  static const int _visibleItemCount = 3;

  double get _calculatedHeight => (_itemHeight * _visibleItemCount) + (_containerPadding * 2);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, -_elevationFactor),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Legend panel centered at bottom with elevation
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.only(right: _toggleRight * 2),
              child: Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                child: Container(
                  width: widget.width,
                  height: _calculatedHeight,
                  padding: const EdgeInsets.all(_containerPadding),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: widget.entries.length,
                    itemBuilder: (context, idx) {
                      final e = widget.entries[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: e.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.label,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        // Toggle button fixed at bottom-right
        Positioned(
          bottom: _toggleBottom,
          right: _toggleRight,
          child: FloatingActionButton(
            mini: true,
            elevation: 0,
            onPressed: _toggle,
            child: Icon(_isOpen ? Icons.keyboard_arrow_down : Icons.legend_toggle),
          ),
        ),
      ],
    );
  }
}