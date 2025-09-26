import 'package:flutter/material.dart';

class CustomTextInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final double? height;

  const CustomTextInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.height,
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
    return SizedBox(
      height: widget.height,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.labelText,
            border: OutlineInputBorder( // Replaced const with a new instance
              borderRadius: BorderRadius.circular(12.0), // Set your desired radius
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}