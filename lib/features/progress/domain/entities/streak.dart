class Streak {
  final int currentDays;
  final int longestDays;
  final DateTime? lastActivityDate;
  Streak({
    required this.currentDays,
    required this.longestDays,
    required this.lastActivityDate,
  });

  bool get isActive {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastActivityDate!);
    return difference.inHours < 24;
  }

  Streak copyWithNewActivity(DateTime activityDate) {
    final different = activityDate.difference(
      lastActivityDate ?? activityDate.subtract(const Duration(days: 1)),
    );
    int newCurrentDays;
    if (different.inHours <= 1) {
      newCurrentDays = currentDays + 1;
    } else if (different.inHours < 24) {
      newCurrentDays = currentDays;
    } else {
      newCurrentDays = 1;
    }
    final newLongestDays = newCurrentDays > longestDays
        ? newCurrentDays
        : longestDays;
    return Streak(
      currentDays: newCurrentDays,
      longestDays: newLongestDays,
      lastActivityDate: activityDate,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'currentDays': currentDays,
      'longestDays': longestDays,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
    };
  }
  factory Streak.fromMap(Map<String, dynamic> map) {
    return Streak(
      currentDays: map['currentDays']?.toInt() ?? 0,
      longestDays: map['longestDays']?.toInt() ?? 0,
      lastActivityDate: map['lastActivityDate'] != null
          ? DateTime.parse(map['lastActivityDate'])
          : null,
    );
  }
}
