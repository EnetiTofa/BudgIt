import 'package:flutter/material.dart';

class SummaryCardBase extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String footerText;
  final Widget child;
  final VoidCallback? onTap;

  const SummaryCardBase({ // V-- Update the constructor
    super.key,
    required this.title,
    required this.footerText,
    required this.child,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            // --- BODY (FILLER) ---
            Expanded(child: Center(child: child)),
            // --- FOOTER ---
            const Divider(height: 1),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    footerText,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onTap != null) const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}