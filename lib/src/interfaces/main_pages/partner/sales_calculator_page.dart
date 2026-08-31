import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../components/primary_button.dart';

class SalesCalculatorPage extends StatefulWidget {
  const SalesCalculatorPage({super.key});

  @override
  State<SalesCalculatorPage> createState() => _SalesCalculatorPageState();
}

class _SalesCalculatorPageState extends State<SalesCalculatorPage> {
  double progress = 0;
  InAppWebViewController? webViewController;
  bool _hasError = false;

  void _reload() {
    setState(() {
      _hasError = false;
      progress = 0;
    });
    webViewController?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          'Sales Calculator',
          style: kBodyTitleM.copyWith(color: const Color(0xFF373737)),
        ),
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF373737)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri('https://register.setgoinnovations.com/sales-calculator'),
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _hasError = false;
                });
              },
              onReceivedError: (controller, request, error) {
                if (request.isForMainFrame ?? true) {
                  setState(() {
                    _hasError = true;
                  });
                }
              },
              onReceivedHttpError: (controller, request, errorResponse) {
                if ((request.isForMainFrame ?? true) &&
                    (errorResponse.statusCode ?? 200) >= 400) {
                  setState(() {
                    _hasError = true;
                  });
                }
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
            ),
            if (progress < 1.0 && !_hasError)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
            if (_hasError)
              Container(
                color: kWhite,
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          size: 40,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Check your internet connection.',
                        style: kBodyTitleM.copyWith(
                          fontSize: 18,
                          color: const Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please verify your connection and tap retry to load the sales calculator.',
                        style: kSmallTitleR.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: 160,
                        height: 44,
                        child: PrimaryButton(
                          text: 'Retry',
                          onPressed: _reload,
                          backgroundColor: kPrimaryColor,
                          textColor: kWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
