import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple state provider that tracks if a dropdown menu is currently visible.
///
/// Other widgets can watch this provider to change their appearance when a menu is active.
final dropdownActiveProvider = StateProvider<bool>((ref) => false);