import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyInputField extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final double initialValue;
  final String? labelText;
  final double? width;
  final double? height;

  const CurrencyInputField({
    super.key,
    required this.onChanged,
    this.initialValue = 0.0,
    this.labelText,
    this.width,
    this.height,
  });

  @override
  State<CurrencyInputField> createState() => _CurrencyInputFieldState();
}

class _CurrencyInputFieldState extends State<CurrencyInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != 0.0) {
      // Always format for display with 2 decimal places initially
      _controller.text = widget.initialValue.toStringAsFixed(2);
    }
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

    // --- THIS IS THE KEY FIX ---
  @override
  void didUpdateWidget(covariant CurrencyInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      final newTextValue = widget.initialValue.toStringAsFixed(2);
      if (_controller.text != newTextValue) {
        // Temporarily remove the listener to prevent the loop.
        _controller.removeListener(_onTextChanged);
        // Programmatically update the text.
        _controller.text = _focusNode.hasFocus ? _formatForEditing(widget.initialValue) : newTextValue;
        // Add the listener back.
        _controller.addListener(_onTextChanged);
      }
    }
  }

  void _onTextChanged() {
    // This will now only be called by user input, not programmatic changes.
    final numericValue = double.tryParse(_controller.text) ?? 0.0;
    widget.onChanged(numericValue);
  }

  void _onFocusChanged() {
    if (mounted) {
      if (_focusNode.hasFocus) {
        // When the field GAINS focus, format for editing (remove .00)
        final value = double.tryParse(_controller.text) ?? 0.0;
        _controller.text = _formatForEditing(value);
      } else if (_controller.text.isNotEmpty) {
        // When the field LOSES focus, format for display (add .00 back)
        final value = double.tryParse(_controller.text) ?? 0.0;
        _controller.text = value.toStringAsFixed(2);
      }
      setState(() {});
    }
  }

  // Removes .00 for whole numbers when editing begins
  String _formatForEditing(double value) {
    final formatted = value.toStringAsFixed(2);

    if (formatted == "0.00") {
      return ""; // remove the whole thing if it's zero
    }

    return formatted.replaceAll(RegExp(r'\.00$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _focusNode.hasFocus ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withValues(alpha: 0.8));

    // This is the core input UI, a TextField overlaid on a RichText for ghost text effect.
    final inputContent = Stack(
      alignment: Alignment.centerLeft,
      children: [
        // The visible text layer (including ghost text)
        // It rebuilds automatically thanks to the controller listener
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) {
            return RichText(
              text: _buildTextSpan(textStyle),
            );
          },
        ),
        // The invisible TextField that actually captures input
        Padding(
          // Pad left to account for the dollar sign
          padding: EdgeInsets.only(left: _calculateDollarSignWidth(textStyle)),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // Input text is transparent; the RichText below provides the visual
            style: textStyle.copyWith(color: Colors.transparent),
            cursorColor: Theme.of(context).colorScheme.primary,
            inputFormatters: [
              // Regex to allow numbers with up to 2 decimal places
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );

    final Widget content;
    // If no label is provided, return the simple input stack.
    // This is used for the budget list where it needs to be compact.
    if (widget.labelText == null) {
      content = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: _focusNode.hasFocus ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: inputContent,
      );
    } else {
      // If a label is provided, wrap in a full decorator.
      content = GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.labelText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          isFocused: _focusNode.hasFocus,
          isEmpty: _controller.text.isEmpty,
          child: inputContent,
        ),
      );
    }

    // Wrap the final widget in a SizedBox to apply optional dimensions.
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: content,
    );
  }

  TextSpan _buildTextSpan(TextStyle textStyle) {
    final ghostStyle = textStyle.copyWith(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5));
    final text = _controller.text;

    // The field is "active" if it has focus or contains text.
    final bool isActive = _focusNode.hasFocus || text.isNotEmpty;

    // If the field isn't active and has no label (compact mode), display nothing.
    if (!isActive && widget.labelText == null) {
      return TextSpan(text: "\$ 0.00", style: ghostStyle);
    }
    
    // If it is not active but has a label, the decorator shows the label, so the field is empty.
    if (!isActive && widget.labelText != null) {
      return const TextSpan(text: '');
    }

    // From here, the field is active, so we always show the dollar sign.
    final spans = <InlineSpan>[
      TextSpan(text: "\$ ", style: textStyle),
    ];

    if (text.isEmpty) {
      // If active but empty, it must be focused. Show the ghost number.
      spans.add(TextSpan(text: "0.00", style: ghostStyle));
      return TextSpan(style: textStyle, children: spans);
    }
    
    // If it has text but is not focused, just show the solid text.
    // The _onFocusChanged listener ensures it's formatted to 2 decimal places.
    if (!_focusNode.hasFocus) {
      spans.add(TextSpan(text: text, style: textStyle));
      return TextSpan(style: textStyle, children: spans);
    }
    
    // If we're here, it's focused and has text. Add ghost text for decimals.
    String solidPart = text;
    String ghostPart = "";
    if (!text.contains('.')) {
      ghostPart = ".00";
    } else {
      final parts = text.split('.');
      if (parts[1].isEmpty) ghostPart = "00";
      else if (parts[1].length == 1) ghostPart = "0";
    }
    spans.add(TextSpan(text: solidPart, style: textStyle));
    spans.add(TextSpan(text: ghostPart, style: ghostStyle));

    return TextSpan(style: textStyle, children: spans);
  }
  
  double _calculateDollarSignWidth(TextStyle style) {
     final textPainter = TextPainter(
      text: TextSpan(text: "\$ ", style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}