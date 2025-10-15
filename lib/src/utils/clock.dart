/// A class that provides the current time. Can be overridden for testing.
class Clock {
  /// The time that the clock is "frozen" at. If null, the clock uses real time.
  final DateTime? forcedTime;

  /// If [forcedTime] is provided, it will be used. Otherwise, `DateTime.now()` is used.
  Clock([this.forcedTime]);

  /// Returns the current time (either real or forced).
  DateTime now() => forcedTime?.toLocal() ?? DateTime.now().toLocal();
}