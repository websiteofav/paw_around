/// Extension methods for String
extension StringExtension on String? {
  /// Returns true if the string is not null and not empty (after trimming)
  bool get isValidString {
    return this != null && this!.trim().isNotEmpty;
  }

  /// Returns the string if valid, otherwise returns the fallback value
  String orDefault(String? fallback) {
    return isValidString ? this! : fallback ?? '';
  }
}

/// Extension methods for List
extension ListExtension<T> on List<T>? {
  /// Returns true if the list is not null and not empty
  bool get isValidList {
    return this != null && this!.isNotEmpty;
  }

  /// Returns the list if valid, otherwise returns an empty list
  List<T> orEmpty() {
    return isValidList ? this! : [];
  }
}
