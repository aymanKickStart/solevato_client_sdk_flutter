import 'package:url_launcher/url_launcher.dart';

class LauncherHandler {
  static Future<void> url({
    required String? url,
  }) async {
    final urlPath = Uri.parse(url ?? '');
    if (await canLaunchUrl(urlPath)) {
      await launchUrl(
        urlPath,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
