import 'package:url_launcher/url_launcher.dart';

/// Utility class for launching URLs
class UrlUtils {
  /// Launches a URL in the default browser or app
  static Future<bool> launch(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    return false;
  }

  /// Launches a URL with custom launch mode
  static Future<bool> launchWithMode(String url, LaunchMode mode) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: mode);
    }

    return false;
  }

  /// Opens Google Maps directions to a location
  static Future<bool> openDirections({
    required double latitude,
    required double longitude,
    String? placeName,
  }) async {
    final query = placeName != null ? Uri.encodeComponent(placeName) : '$latitude,$longitude';

    final url = 'https://www.google.com/maps/dir/?api=1&destination=$query';

    return await launch(url);
  }

  /// Opens Google Maps to a specific place
  static Future<bool> openGoogleMaps({
    required double latitude,
    required double longitude,
  }) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    return await launch(url);
  }

  /// Opens phone dialer with a number
  static Future<bool> openPhone(String phoneNumber) async {
    final url = 'tel:$phoneNumber';

    return await launch(url);
  }

  /// Opens email client
  static Future<bool> openEmail(String email, {String? subject, String? body}) async {
    // Build mailto URL manually to avoid encoding issues
    String mailtoUrl = 'mailto:$email';
    final params = <String>[];

    if (subject != null) {
      params.add('subject=${Uri.encodeComponent(subject)}');
    }
    if (body != null) {
      params.add('body=${Uri.encodeComponent(body)}');
    }

    if (params.isNotEmpty) {
      mailtoUrl += '?${params.join('&')}';
    }

    final uri = Uri.parse(mailtoUrl);

    try {
      // Don't use canLaunchUrl for mailto - it's unreliable on Android
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }

  /// Opens a website in in-app browser
  static Future<bool> openWebsite(String url) async {
    return await launchWithMode(url, LaunchMode.inAppBrowserView);
  }
}
