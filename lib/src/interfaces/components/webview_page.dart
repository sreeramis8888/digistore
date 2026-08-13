import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';

class InAppWebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const InAppWebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: kSubHeadingM.copyWith(color: kTextColor),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialSettings: InAppWebViewSettings(transparentBackground: true),
              initialUrlRequest: URLRequest(
                url: WebUri(widget.url),
              ),
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
