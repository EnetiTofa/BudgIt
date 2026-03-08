// lib/src/common_widgets/custom_text_input_field.dart

import 'package:flutter/material.dart';

class CustomTextInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final double? height;
  final List<String>? suggestions; // --- NEW: Optional suggestions list ---

  const CustomTextInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.height,
    this.suggestions,
  });

  @override
  State<CustomTextInputField> createState() => _CustomTextInputFieldState();
}

class _CustomTextInputFieldState extends State<CustomTextInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Re-render on focus change to update the decorator's label position
    _focusNode.addListener(_updateState);
    // Re-render on text change to ensure the label doesn't overlap typed text
    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_updateState);
    widget.controller.removeListener(_updateState);
    _focusNode.dispose();
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  // Extracted your exact styling into a helper method so it remains identical
  Widget _buildInputField(
    TextEditingController controller,
    FocusNode focusNode, [
    VoidCallback? onFieldSubmitted,
  ]) {
    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        isFocused: focusNode.hasFocus,
        isEmpty: controller.text.isEmpty,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onSubmitted: onFieldSubmitted != null
              ? (_) => onFieldSubmitted()
              : null,
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
  Widget build(BuildContext context) {
    final hasSuggestions =
        widget.suggestions != null && widget.suggestions!.isNotEmpty;

    Widget content;

    if (hasSuggestions) {
      // --- MODE 1: Autocomplete Dropdown ---
      content = LayoutBuilder(
        builder: (context, constraints) {
          return RawAutocomplete<String>(
            textEditingController: widget.controller,
            focusNode: _focusNode,
            optionsBuilder: (TextEditingValue textEditingValue) {
              // --- CHANGED: Show all options when the field is empty ---
              if (textEditingValue.text.isEmpty) {
                return widget.suggestions!;
              }
              final keywordLower = textEditingValue.text.toLowerCase();
              return widget.suggestions!.where((String option) {
                return option.toLowerCase().contains(keywordLower);
              });
            },
            onSelected: (String selection) {
              _focusNode.unfocus();
            },
            fieldViewBuilder:
                (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return _buildInputField(
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  );
                },
            optionsViewBuilder:
                (
                  BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options,
                ) {
                  final theme = Theme.of(context);
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 8.0,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 250,
                          maxWidth: constraints.biggest.width,
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  option,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
          );
        },
      );
    } else {
      // --- MODE 2: Standard Text Field ---
      content = _buildInputField(widget.controller, _focusNode);
    }

    return SizedBox(height: widget.height, child: content);
  }
}
