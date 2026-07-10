import 'dart:io';

class DevHttpOverrides extends HttpOverrides {
  final String proxyHost;
  final String proxyPort;

  DevHttpOverrides({required this.proxyHost, required this.proxyPort});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..findProxy = (uri) {
        return "PROXY $proxyHost:$proxyPort";
      }
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
