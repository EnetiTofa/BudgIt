import 'package:flutter/material.dart';

class SummaryCardBase extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? footerText; // Made Optional
  final Widget child;
  final VoidCallback? onTap;

  const SummaryCardBase({
    super.key,
    required this.title,
    this.footerText, // No longer required
    required this.child,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // If footer exists, use slightly less bottom padding to accommodate the footer row
        padding: footerText != null 
            ? const EdgeInsets.fromLTRB(16, 16, 16, 10) 
            : const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Text(
              title, 
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16.0, 
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            
            // --- BODY ---
            Expanded(child: Center(child: child)),
            
            // --- FOOTER (Conditional) ---
            if (footerText != null) ...[
              const Divider(height: 1),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      footerText!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null) const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}