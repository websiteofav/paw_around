/// Date utility functions for the Paw Around app
class AppDateUtils {
  // Private constructor to prevent instantiation
  AppDateUtils._();

  // Month names
  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static const List<String> _shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  static const List<String> _shortDayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Format date to readable string (e.g., "January 15, 2024")
  static String formatDateLong(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format date to short string (e.g., "Jan 15, 2024")
  static String formatDateShort(DateTime date) {
    return '${_shortMonthNames[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  /// Format date to very short string (e.g., "15/01/24")
  static String formatDateNumeric(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }

  /// Format date with day name (e.g., "Monday, Jan 15, 2024")
  static String formatDateWithDay(DateTime date) {
    final dayName = _shortDayNames[date.weekday - 1];
    return '$dayName, ${formatDateShort(date)}';
  }

  /// Format date for display in cards (e.g., "Jan 15")
  static String formatDateCard(DateTime date) {
    return '${_shortMonthNames[date.month - 1]} ${date.day}';
  }

  /// Format date for file names (e.g., "2024-01-15")
  static String formatDateForFile(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format time (e.g., "2:30 PM")
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Format date and time (e.g., "Jan 15, 2024 at 2:30 PM")
  static String formatDateTime(DateTime dateTime) {
    return '${formatDateShort(dateTime)} at ${formatTime(dateTime)}';
  }

  /// Calculate age from date of birth
  static int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Calculate age in months
  static int calculateAgeInMonths(DateTime dateOfBirth) {
    final now = DateTime.now();
    return (now.year - dateOfBirth.year) * 12 + (now.month - dateOfBirth.month);
  }

  /// Calculate days until a future date
  static int daysUntil(DateTime futureDate) {
    final now = DateTime.now();
    return futureDate.difference(now).inDays;
  }

  /// Calculate days since a past date
  static int daysSince(DateTime pastDate) {
    final now = DateTime.now();
    return now.difference(pastDate).inDays;
  }

  /// Check if a date is overdue
  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  /// Check if a date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// Get relative time string (e.g., "2 days ago", "in 3 hours")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get relative time for future dates (e.g., "in 2 days", "in 3 hours")
  static String getRelativeFutureTime(DateTime futureDateTime) {
    final now = DateTime.now();
    final difference = futureDateTime.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Now';
    }
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Add months to date
  static DateTime addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }

  /// Add years to date
  static DateTime addYears(DateTime date, int years) {
    return DateTime(date.year + years, date.month, date.day);
  }

  /// Get days in month
  static int daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Check if year is leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get week number of year
  static int getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(startOfYear).inDays;
    return (daysSinceStart / 7).ceil();
  }

  /// Format duration (e.g., "2 hours 30 minutes")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours hour${hours == 1 ? '' : 's'} $minutes minute${minutes == 1 ? '' : 's'}';
    } else if (minutes > 0) {
      return '$minutes minute${minutes == 1 ? '' : 's'} $seconds second${seconds == 1 ? '' : 's'}';
    } else {
      return '$seconds second${seconds == 1 ? '' : 's'}';
    }
  }

  /// Parse date from string (supports multiple formats)
  static DateTime? parseDate(String dateString) {
    try {
      // Try common formats
      final formats = [
        'yyyy-MM-dd',
        'dd/MM/yyyy',
        'MM/dd/yyyy',
        'dd-MM-yyyy',
        'MM-dd-yyyy',
        'yyyy/MM/dd',
      ];

      for (final format in formats) {
        try {
          // Simple parsing for common formats
          if (format == 'yyyy-MM-dd') {
            final parts = dateString.split('-');
            if (parts.length == 3) {
              return DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );
            }
          } else if (format == 'dd/MM/yyyy') {
            final parts = dateString.split('/');
            if (parts.length == 3) {
              return DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            }
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Get date range for last N days
  static List<DateTime> getLastNDays(int days) {
    final now = DateTime.now();
    return List.generate(days, (index) {
      return now.subtract(Duration(days: days - 1 - index));
    });
  }

  /// Get date range for next N days
  static List<DateTime> getNextNDays(int days) {
    final now = DateTime.now();
    return List.generate(days, (index) {
      return now.add(Duration(days: index + 1));
    });
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  /// Get human readable date range (e.g., "Jan 15 - Jan 20, 2024")
  static String formatDateRange(DateTime startDate, DateTime endDate) {
    if (isSameDay(startDate, endDate)) {
      return formatDateShort(startDate);
    } else if (startDate.year == endDate.year) {
      if (startDate.month == endDate.month) {
        return '${_shortMonthNames[startDate.month - 1]} ${startDate.day} - ${endDate.day}, ${startDate.year}';
      } else {
        return '${formatDateShort(startDate)} - ${formatDateShort(endDate)}';
      }
    } else {
      return '${formatDateShort(startDate)} - ${formatDateShort(endDate)}';
    }
  }

}
