import 'package:url_launcher/url_launcher.dart';


enum LaunchModeOption {
  inAppWebView,
  externalApplication,
}

Future<void> launchURL(
  String rawUrl, {
  LaunchModeOption mode = LaunchModeOption.externalApplication,
}) async {
  if (rawUrl.isEmpty) {
    print('URL is empty');
    return;
  }

  String url = rawUrl.trim();

  // Add scheme if missing
  if (!url.startsWith(RegExp(r'https?://'))) {
    url = 'https://$url';
  }

  Uri? uri;

  try {
    uri = Uri.parse(url);
  } catch (e) {
    print('Invalid URL: $url');
    return;
  }

  final launchMode = mode == LaunchModeOption.inAppWebView
      ? LaunchMode.inAppWebView
      : LaunchMode.externalApplication;

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: launchMode);
    } else {
      print('Cannot launch URL: $url');
    }
  } catch (e) {
    print('Launch error: $e');
  }
}


Future<void> openGoogleMaps(String location) async {
  final Uri googleMapsUrl =
      Uri.parse("https://www.google.com/maps/search/?api=1&query=$location");

  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(googleMapsUrl);
  } else {
    print('Failed to load maps');
  }
}


  void launchPhone(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

      await launchUrl(uri);
 
  }

  void launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    
      await launchUrl(uri);

  }
