import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place_suggestion.dart';
import '../../view_models/search_viewmodel.dart';

/// A minimal, clean search bar with a leading icon.
/// The icon stays aligned with the text field even when the
/// suggestions dropdown expands underneath.
class MinimalSearchField extends StatelessWidget {
  const MinimalSearchField({
    super.key,
    required this.icon,
    required this.hintText,
    this.onSelected,
  });

  final IconData icon;
  final String hintText;
  final ValueChanged<PlaceSuggestion>? onSelected;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: _Inner(icon: icon, hintText: hintText, onSelected: onSelected),
    );
  }
}

class _Inner extends StatefulWidget {
  const _Inner({required this.icon, required this.hintText, this.onSelected});

  final IconData icon;
  final String hintText;
  final ValueChanged<PlaceSuggestion>? onSelected;

  @override
  State<_Inner> createState() => _InnerState();
}

class _InnerState extends State<_Inner> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  static const _iconAreaWidth = 40.0;
  static const _barHeight = 48.0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        context.read<SearchViewModel>().clearSuggestions();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: _iconAreaWidth - 4,
              height: _barHeight,
              child: Center(
                child: Icon(widget.icon, size: 20, color: Colors.grey[700]),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: vm.onQueryChanged,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(color: Color(0xFF8C8C8C)),
                  filled: true,
                  fillColor: const Color(0xFFE7E5E5),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.indigo),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: vm.loading
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),

        if (vm.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: _iconAreaWidth),
            child: Container(
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: vm.items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 12, endIndent: 12),
                itemBuilder: (context, i) {
                  final suggestion = vm.items[i];
                  return ListTile(
                    dense: true,
                    title: Text(
                      suggestion.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      suggestion.label,
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    ),

                    onTap: () {
                      _controller.text = suggestion.label;
                      widget.onSelected?.call(suggestion);
                      context.read<SearchViewModel>().clearSuggestions();
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
