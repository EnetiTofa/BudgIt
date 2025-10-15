// lib/src/common_widgets/pulsing_button.dart
import 'package:flutter/material.dart';

class PulsingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  // --- MODIFICATION: Added optional parameters for intensity ---
  final double pulseExtent;
  final double maxOpacity;

  const PulsingButton({
    super.key, 
    required this.onPressed, 
    required this.label,
    this.pulseExtent = 50.0,
    this.maxOpacity = 0.2,
  });

  @override
  State<PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary.withAlpha(230);
    const double buttonSize = 220;
    // --- MODIFICATION: Define a fixed container size to prevent layout jiggle ---
    final double containerSize = buttonSize + widget.pulseExtent;

    return Center(
      // --- MODIFICATION: Wrap the Stack in a SizedBox to give it a fixed size ---
      child: SizedBox(
        width: containerSize,
        height: containerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple effect
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    _buildRipple(color, buttonSize: buttonSize, delay: 0.0),
                    _buildRipple(color, buttonSize: buttonSize, delay: 0.5),
                  ],
                );
              },
            ),
            // The main button
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: FilledButton(
                onPressed: widget.onPressed,
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: color,
                  foregroundColor: theme.colorScheme.surface,
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.surface,
                      fontWeight: FontWeight.w700,
                      height: 1
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRipple(Color color, {required double buttonSize, required double delay}) {
    final double animationValue = (_animationController.value + (1.0 - delay)) % 1.0;
    final double curvedValue = Curves.easeInOut.transform(animationValue);
    
    final double size = buttonSize + (widget.pulseExtent * curvedValue);
    final double opacity = widget.maxOpacity * (1 - curvedValue);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity.clamp(0.0, 1.0)),
      ),
    );
  }
}