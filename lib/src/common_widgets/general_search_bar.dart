import 'package:flutter/material.dart';

class GeneralSearchBar extends StatefulWidget {
  final String initialQuery;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasOutline;
  final Color? backgroundColor;
  final bool useLabelText; // New property to control text behavior

  const GeneralSearchBar({
    super.key,
    this.initialQuery = '',
    this.hintText = 'Search...',
    required this.onChanged,
    required this.onClear,
    this.hasOutline = true,
    this.backgroundColor,
    this.useLabelText = true, // Default to original label behavior
  });

  @override
  State<GeneralSearchBar> createState() => _GeneralSearchBarState();
}

class _GeneralSearchBarState extends State<GeneralSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();

    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool isActive = _focusNode.hasFocus;
    final Color activeColor = colorScheme.primary;
    final Color inactiveColor = colorScheme.secondary;
    final Color activeElementsColor = isActive ? activeColor : inactiveColor;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: activeElementsColor),
      decoration: InputDecoration(
        // Conditionally use labelText or hintText based on the new property
        labelText: widget.useLabelText ? widget.hintText : null,
        hintText: widget.useLabelText ? null : widget.hintText,
        labelStyle: TextStyle(color: activeElementsColor),
        hintStyle: TextStyle(color: inactiveColor.withOpacity(0.6)),
        prefixIcon: Icon(
          Icons.search,
          color: activeElementsColor,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: widget.hasOutline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: activeElementsColor, width: 1),
              )
            : null,
        focusedBorder: widget.hasOutline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: activeColor, width: 1.5),
              )
            : null,
        filled: widget.backgroundColor != null,
        fillColor: widget.backgroundColor,
        isDense: true,
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: activeElementsColor,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onClear();
                },
              )
            : null,
      ),
      onChanged: widget.onChanged,
    );
  }
}