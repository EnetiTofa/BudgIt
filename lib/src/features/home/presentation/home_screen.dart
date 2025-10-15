// lib/src/features/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- MODIFICATION: Removed Scaffold and AppBar ---
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        Text('Coming Soon'),
        TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '',
          ),
          autofocus: false,
          enabled: true,
        )
      ],
    );
  }
}