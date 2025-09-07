import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'screen_layout.g.dart';

@HiveType(typeId: 11)
class ScreenLayout extends Equatable with HiveObjectMixin {
  ScreenLayout({
    required this.screenId,
    required this.widgetOrder,
    required this.defaultWidget,
  });

  @HiveField(0)
  final String screenId;
  @HiveField(1)
  final List<String> widgetOrder;
  @HiveField(2)
  final String defaultWidget;

  @override
  List<Object?> get props => [screenId, widgetOrder, defaultWidget];
}