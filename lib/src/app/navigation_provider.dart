// lib/src/app/navigation_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

/// This provider holds the index of the currently selected page
/// in the main AppShell's BottomAppBar.
@Riverpod(keepAlive: true)
class MainPageIndex extends _$MainPageIndex {
  @override
  int build() => 0; // Default to the first page (HomeScreen)

  void setIndex(int index) {
    state = index;
  }
}

/// This provider can control the selected tab within the Transaction Hub
/// (e.g., 0 for the Log, 1 for Recurring).
@Riverpod(keepAlive: true)
class TransactionHubTabIndex extends _$TransactionHubTabIndex {
  @override
  int build() => 0; // Default to the first tab

  void setIndex(int index) {
    state = index;
  }
}