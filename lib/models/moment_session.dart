class MomentSession {
  final int day, minutes;
  final DateTime start;
  const MomentSession(this.day, this.minutes, this.start);
  DateTime get end => start.add(Duration(minutes: minutes));
}