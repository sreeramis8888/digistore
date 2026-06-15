import 'package:flutter/material.dart';
import 'package:setgo/src/data/constants/color_constants.dart';
import 'package:setgo/src/data/constants/style_constants.dart';
import 'package:url_launcher/url_launcher.dart';
class UpdateMaintenanceOverlay extends StatelessWidget {
  final bool isMaintenance;
  final bool isHardUpdate;
  final bool isSoftUpdate;
  final String title;
  final String message;
  final String? updateUrl;
  final VoidCallback? onDismiss;

  const UpdateMaintenanceOverlay({
    super.key,
    required this.isMaintenance,
    required this.isHardUpdate,
    required this.isSoftUpdate,
    required this.title,
    required this.message,
    this.updateUrl,
    this.onDismiss,
  });

  Future<void> _launchUrl() async {
    if (updateUrl != null && updateUrl!.isNotEmpty) {
      final Uri url = Uri.parse(updateUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      left: 16,
      right: 16,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 0.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value * 200),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isMaintenance ? Colors.orange : kPrimaryColor).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isMaintenance ? Icons.build_circle_rounded : Icons.system_update_rounded,
                        size: 28,
                        color: isMaintenance ? Colors.orange : kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: kSubHeadingB,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: kSmallTitleR.copyWith(color: kSecondaryTextColor, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isSoftUpdate && !isHardUpdate)
                      TextButton(
                        onPressed: onDismiss,
                        style: TextButton.styleFrom(
                          foregroundColor: kSecondaryTextColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Later',
                          style: kBodyTitleM,
                        ),
                      ),
                    if (isSoftUpdate && !isHardUpdate) const SizedBox(width: 8),
                    if (!isMaintenance && (isHardUpdate || isSoftUpdate))
                      ElevatedButton(
                        onPressed: _launchUrl,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: kWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Update',
                          style: kBodyTitleM.copyWith(color: kWhite),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
