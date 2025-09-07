import 'package:flutter/material.dart';

class CustomTextInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  const CustomTextInputField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  State<CustomTextInputField> createState() => _CustomTextInputFieldState();
}

class _CustomTextInputFieldState extends State<CustomTextInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {}); // Re-render on focus change to update the decorator
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        isFocused: _focusNode.hasFocus,
        isEmpty: widget.controller.text.isEmpty,
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}