import 'package:flutter/material.dart';

class CustomizerCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;

  const CustomizerCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isFirst,
    required this.isLast,
    required this.onMoveLeft,
    required this.onMoveRight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: 140, // Set a fixed width
      child: Column(
        children: [
          // Use an AspectRatio with a factor of 1.0 to make the card a square
          AspectRatio(
            aspectRatio: 1.0,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outline, width: 1.5),
              ),
              color: theme.colorScheme.surfaceContainer,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: Row(
              // --- This is the new logic for centering the end arrows ---
              mainAxisAlignment: isFirst || isLast 
                  ? MainAxisAlignment.center 
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!isFirst) IconButton(icon: const Icon(Icons.arrow_back), onPressed: onMoveLeft),
                if (!isLast) IconButton(icon: const Icon(Icons.arrow_forward), onPressed: onMoveRight),
              ],
            ),
          )
        ],
      ),
    );
  }
}