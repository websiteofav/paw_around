import 'dart:convert';

enum PendingIntentSource {
  localNotification,
  pushNotification,
  deepLink,
}

enum PendingIntentType {
  actionReminder,
  route,
}

class PendingIntent {
  final PendingIntentSource source;
  final PendingIntentType type;
  final bool requiresAuth;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const PendingIntent({
    required this.source,
    required this.type,
    required this.requiresAuth,
    required this.payload,
    required this.createdAt,
  });

  factory PendingIntent.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    return PendingIntent(
      source: PendingIntentSource.values.firstWhere(
        (value) => value.name == json['source'],
        orElse: () => PendingIntentSource.localNotification,
      ),
      type: PendingIntentType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => PendingIntentType.route,
      ),
      requiresAuth: json['requiresAuth'] as bool? ?? true,
      payload: payload is Map<String, dynamic>
          ? payload
          : Map<String, dynamic>.from(payload as Map),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.name,
      'type': type.name,
      'requiresAuth': requiresAuth,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get dedupeKey {
    return '${source.name}:${type.name}:${jsonEncode(payload)}';
  }
}
