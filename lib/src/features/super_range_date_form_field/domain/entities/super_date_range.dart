/// Immutable date-only range used by [SuperRangeDateFormField].
///
/// The controller normalizes both boundaries to midnight before exposing a
/// value, so consumers can compare dates without time-of-day noise.
class SuperDateRange {
  const SuperDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);

  SuperDateRange copyWith({DateTime? start, DateTime? end}) {
    return SuperDateRange(start: start ?? this.start, end: end ?? this.end);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SuperDateRange && start == other.start && end == other.end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'SuperDateRange(start: $start, end: $end)';
}
