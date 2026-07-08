import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../config/api_config.dart';
import '../models/cake.dart';
import 'cake_link.dart';
import 'cake_visuals.dart';
import 'currency_formatter.dart';

class CakeShare {
  static Future<void> shareCake(
    Cake cake, {
    required String shareBaseUrl,
  }) async {
    final link = CakeLink.productPageFromRoot(cake.id, shareBaseUrl);
    final price = CurrencyFormatter.format(cake.basePrice);
    final text =
        '${cake.name}\n$price · ${cake.description}\n\n'
        'Order on Sweet Delights:\n$link';

    final imageUrl = CakeVisuals.networkUrlFor(cake);
    if (imageUrl != null) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          final dir = await getTemporaryDirectory();
          final safeId = cake.id.replaceAll(RegExp(r'[^\w]'), '_');
          final file = File('${dir.path}/sweet_delights_$safeId.jpg');
          await file.writeAsBytes(response.bodyBytes);

          await Share.shareXFiles(
            [XFile(file.path, mimeType: 'image/jpeg')],
            text: text,
            subject: cake.name,
          );
          return;
        }
      } catch (_) {
        // Fall back to text-only share below.
      }
    }

    await Share.share(text, subject: cake.name);
  }

  static bool isPublicShareUrl(String shareBaseUrl) {
    final uri = Uri.tryParse(shareBaseUrl);
    if (uri == null || uri.host.isEmpty) return false;
    return !isLocalOrPrivateHost(uri.host);
  }
}
