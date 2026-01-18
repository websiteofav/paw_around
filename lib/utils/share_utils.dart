import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:paw_around/constants/api_constants.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:paw_around/models/community/lost_found_post.dart';

class ShareUtils {
  /// Get the deep link URL for a post
  static String getPostUrl(LostFoundPost post) {
    return '${ApiConstants.pawAroundBaseUrl}/${AppStrings.community}/${post.id}';
  }

  /// Share a post with optional image
  static Future<void> sharePost(LostFoundPost post) async {
    final url = getPostUrl(post);
    final type = post.type == PostType.lost ? 'Lost' : 'Found';
    final text = '''
$type Pet Alert!

$type: ${post.petName}
Breed: ${post.breed}
Location: ${post.locationName}

${post.petDescription}

Help reunite this pet!
$url
''';

    if (post.imagePath != null && post.imagePath!.startsWith('http')) {
      await _shareWithImage(text, post.imagePath!);
    } else {
      await SharePlus.instance.share(ShareParams(text: text));
    }
  }

  /// Download image and share with text
  static Future<void> _shareWithImage(String text, String imageUrl) async {
    try {
      // Download image to temp directory
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        await SharePlus.instance.share(ShareParams(text: text));
        return;
      }

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/share_image.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Share with image using ShareParams
      final params = ShareParams(
        text: text,
        files: [XFile(filePath)],
      );
      await SharePlus.instance.share(params);
    } catch (e) {
      // Fallback to text-only share
      await SharePlus.instance.share(ShareParams(text: text));
    }
  }
}
