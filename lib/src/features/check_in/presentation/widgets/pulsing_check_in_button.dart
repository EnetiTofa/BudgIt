// lib/src/features/check_in/presentation/widgets/pulsing_check_in_button.dart
import 'package:flutter/material.dart';

class PulsingCheckInButton extends StatefulWidget {
  final VoidCallback onPressed;

  const PulsingCheckInButton({super.key, required this.onPressed});

  @override
  State<PulsingCheckInButton> createState() => _PulsingCheckInButtonState();
}

class _PulsingCheckInButtonState extends State<PulsingCheckInButton>
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
    final color = theme.colorScheme.primary;

    return Center(
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
                  // Each ripple is slightly delayed for a better effect
                  _buildRipple(color, delay: 0.0),
                  _buildRipple(color, delay: 0.5),
                ],
              );
            },
          ),
          // The main button
          SizedBox(
            width: 180,
            height: 180,
            child: FilledButton(
              onPressed: widget.onPressed,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: color,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text(
                'Check In',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipple(Color color, {required double delay}) {
    // Create a value that cycles from 0.0 to 1.0 based on the controller and a delay
    final double animationValue = (_animationController.value + (1.0 - delay)) % 1.0;
    // Use a curve to make the ripple's growth and fade feel more natural
    final double curvedValue = Curves.easeInOut.transform(animationValue);

    final double size = 180 + (120 * curvedValue); // Ripple grows
    final double opacity = 0.5 * (1 - curvedValue); // Ripple fades out

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