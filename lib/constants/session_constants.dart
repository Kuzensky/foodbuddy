/// Session-related constants and enums for FoodBuddy
enum SessionStatus {
  open,
  full,
  completed,
  cancelled,
}

enum SessionUserRelation {
  none,
  host,
  joined,
  pending,
  rejected,
  left,
}

class SessionConstants {
  static const int defaultMaxParticipants = 6;
  static const int minimumNoticeHours = 1;
  static const Duration sessionCacheDuration = Duration(minutes: 5);
  static const Duration pendingRequestCooldown = Duration(hours: 24);

  static String getSessionStatusString(SessionStatus status) {
    switch (status) {
      case SessionStatus.open:
        return 'open';
      case SessionStatus.full:
        return 'full';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.cancelled:
        return 'cancelled';
    }
  }

  static SessionStatus getSessionStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return SessionStatus.open;
      case 'full':
        return SessionStatus.full;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      default:
        return SessionStatus.open;
    }
  }
}