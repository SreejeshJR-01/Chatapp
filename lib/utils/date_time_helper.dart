import 'package:intl/intl.dart';

class DateTimeHelper {
  /// Format message timestamp for display in chat conversation
  /// Shows time in HH:mm format (e.g., "14:30")
  static String formatMessageTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format timestamp for chat list display
  /// Shows:
  /// - Time (HH:mm) if message is from today
  /// - "Yesterday" if message is from yesterday
  /// - Date (MMM dd) if message is older (e.g., "Nov 20")
  static String formatChatListTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get date separator text for grouping messages
  /// Shows:
  /// - "Today" if date is today
  /// - "Yesterday" if date is yesterday
  /// - Full date (MMMM dd, yyyy) for older dates (e.g., "November 20, 2025")
  static String getDateSeparator(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM dd, yyyy').format(dateTime);
    }
  }

  /// Determine if a date separator should be shown between two messages
  /// Returns true if the messages are from different days
  static bool shouldShowDateSeparator(DateTime? previousMessageTime, DateTime currentMessageTime) {
    if (previousMessageTime == null) {
      return true;
    }
    return !isSameDay(previousMessageTime, currentMessageTime);
  }
}
