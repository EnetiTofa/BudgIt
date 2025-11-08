import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/core/data/repositories/settings_repository.dart';

part 'settings_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<SettingsRepository> settingsRepository(SettingsRepositoryRef ref) async {
  final repository = SettingsRepository();
  await repository.init();
  return repository;
}