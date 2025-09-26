import 'package:flutter/material.dart';

class GeneralSearchBar extends StatefulWidget {
  final String initialQuery;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasOutline;
  final Color? backgroundColor;

  const GeneralSearchBar({
    super.key,
    this.initialQuery = '',
    this.hintText = 'Search...',
    required this.onChanged,
    required this.onClear,
    this.hasOutline = true,
    this.backgroundColor,
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

    // Add listeners to rebuild the widget when focus or text changes
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
    
    // Determine colors based on focus state
    final bool isActive = _focusNode.hasFocus;
    final Color activeColor = colorScheme.primary; // Active color is now white
    final Color inactiveColor = colorScheme.secondary;
    final Color activeElementsColor = isActive ? activeColor : inactiveColor;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: activeElementsColor),
      decoration: InputDecoration(
        labelStyle: TextStyle(color: activeElementsColor),
        labelText: widget.hintText,
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
        filled: widget.backgroundColor != null,
        fillColor: widget.backgroundColor,
        isDense: true,
        // Conditionally show the clear button
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: activeElementsColor,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onClear();
                  // Optionally, you can request focus to stay
                  // _focusNode.requestFocus();
                },
              )
            : null, // Render nothing if there is no text
      ),
      onChanged: widget.onChanged,
    );
  }
}