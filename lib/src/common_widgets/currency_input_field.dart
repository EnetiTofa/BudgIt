import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CurrencyInputFieldStyle {
  outlined,
  borderless,
}

class CurrencyInputField extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final double initialValue;
  final String? labelText;
  final double? width;
  final double? height;
  final CurrencyInputFieldStyle style;
  final TextStyle? textStyle;
  // --- NEW: Add a backgroundColor property ---
  final Color? backgroundColor;

  const CurrencyInputField({
    super.key,
    required this.onChanged,
    this.initialValue = 0.0,
    this.labelText,
    this.width,
    this.height,
    this.style = CurrencyInputFieldStyle.outlined,
    this.textStyle,
    // Initialize the new property in the constructor
    this.backgroundColor,
  });

  @override
  State<CurrencyInputField> createState() => _CurrencyInputFieldState();
}

class _CurrencyInputFieldState extends State<CurrencyInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // ... (initState and other methods remain the same) ...
  @override
  void initState() {
    super.initState();
    if (widget.initialValue != 0.0) {
      _controller.text = widget.initialValue.toStringAsFixed(2);
    }
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant CurrencyInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      final newTextValue = widget.initialValue.toStringAsFixed(2);
      if (_controller.text != newTextValue) {
        _controller.removeListener(_onTextChanged);
        _controller.text = _focusNode.hasFocus
            ? _formatForEditing(widget.initialValue)
            : newTextValue;
        _controller.addListener(_onTextChanged);
      }
    }
  }

  void _onTextChanged() {
    final numericValue = double.tryParse(_controller.text) ?? 0.0;
    widget.onChanged(numericValue);
  }

  void _onFocusChanged() {
    if (mounted) {
      if (_focusNode.hasFocus) {
        final value = double.tryParse(_controller.text) ?? 0.0;
        _controller.text = _formatForEditing(value);
      } else if (_controller.text.isNotEmpty) {
        final value = double.tryParse(_controller.text) ?? 0.0;
        _controller.text = value.toStringAsFixed(2);
      }
      setState(() {});
    }
  }

  String _formatForEditing(double value) {
    if (value == 0.0) return "";
    return value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface);
    final textStyle = defaultStyle.merge(widget.textStyle);

    final inputContent = Stack(
      alignment: Alignment.centerLeft,
      children: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) {
            return RichText(text: _buildTextSpan(textStyle));
          },
        ),
        Padding(
          padding:
              EdgeInsets.only(left: _calculateDollarSignWidth(textStyle)),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: textStyle.copyWith(color: Colors.transparent),
            cursorColor: Theme.of(context).colorScheme.primary,
            inputFormatters: [
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
    switch (widget.style) {
      case CurrencyInputFieldStyle.borderless:
        content = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            // --- MODIFIED: Use the backgroundColor, defaulting to transparent ---
            color: widget.backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: inputContent,
        );
        break;
      case CurrencyInputFieldStyle.outlined:
        if (widget.labelText == null) {
          content = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            decoration: BoxDecoration(
              // --- MODIFIED: Added backgroundColor here as well ---
              color: widget.backgroundColor ?? Colors.transparent,
              border: Border.all(
                  color: _focusNode.hasFocus
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: inputContent,
          );
        } else {
          content = GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.labelText,
                // --- MODIFIED: Added fill color for the outlined decorator style ---
                fillColor: widget.backgroundColor,
                filled: widget.backgroundColor != null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              isFocused: _focusNode.hasFocus,
              isEmpty: _controller.text.isEmpty,
              child: inputContent,
            ),
          );
        }
        break;
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: content,
    );
  }

  TextSpan _buildTextSpan(TextStyle textStyle) {
    final ghostStyle =
        textStyle.copyWith(color: textStyle.color?.withOpacity(0.5));
    final text = _controller.text;
    final bool isActive = _focusNode.hasFocus || text.isNotEmpty;

    if (!isActive && widget.labelText == null) {
      return TextSpan(text: "\$ 0.00", style: ghostStyle);
    }
    if (!isActive && widget.labelText != null) {
      return const TextSpan(text: '');
    }

    final spans = <InlineSpan>[TextSpan(text: "\$ ", style: textStyle)];

    if (text.isEmpty) {
      spans.add(TextSpan(text: "0.00", style: ghostStyle));
      return TextSpan(style: textStyle, children: spans);
    }
    if (!_focusNode.hasFocus) {
      spans.add(TextSpan(text: text, style: textStyle));
      return TextSpan(style: textStyle, children: spans);
    }
    String solidPart = text;
    String ghostPart = "";
    if (!text.contains('.')) {
      ghostPart = ".00";
    } else {
      final parts = text.split('.');
      if (parts[1].isEmpty) ghostPart = "00";
      if (parts[1].length == 1) ghostPart = "0";
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

extension ColorValues on Color {
  Color withValues({double? alpha, double? red, double? green, double? blue}) {
    return Color.fromARGB(
      (alpha != null ? (alpha * 255).round() : this.alpha),
      (red != null ? (red * 255).round() : this.red),
      (green != null ? (green * 255).round() : this.green),
      (blue != null ? (blue * 255).round() : this.blue),
    );
  }
}