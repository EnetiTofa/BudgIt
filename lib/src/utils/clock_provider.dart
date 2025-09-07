import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/utils/clock.dart';

part 'clock_provider.g.dart';

@Riverpod(keepAlive: true)
Clock clock(Ref ref) {
  return Clock();
}