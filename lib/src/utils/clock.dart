/// A simple class to abstract away DateTime.now() to make testing easier.
class Clock {
  DateTime now() => DateTime.now().toLocal();
}