import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';

class SalesCalculatorPage extends StatefulWidget {
  const SalesCalculatorPage({super.key});

  @override
  State<SalesCalculatorPage> createState() => _SalesCalculatorPageState();
}

class _SalesCalculatorPageState extends State<SalesCalculatorPage> {
  double progress = 0;
  late InAppWebViewController webViewController;

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
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
            ),
            if (progress < 1.0)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
          ],
        ),
      ),
    );
  }
}
