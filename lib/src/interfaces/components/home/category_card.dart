import 'package:setgo/src/data/constants/style_constants.dart';
import 'package:setgo/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../safe_network_icon.dart';

class CategoryCard extends ConsumerWidget {
  final Map<String, dynamic> category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Container(
      width: screenSize.responsivePadding(80),
      height: screenSize.responsivePadding(118),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFF96D4FB)],
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.responsivePadding(12),
          horizontal: screenSize.responsivePadding(4),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB0DFF9), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: screenSize.responsivePadding(55),
              height: screenSize.responsivePadding(55),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF5F5F5).withOpacity(.55),
              ),
              child: Center(child: _buildIcon(category['icon'] as String)),
            ),
            SizedBox(height: screenSize.responsivePadding(8)),
            Text(
              category['name'] as String,
              style: kSmallTitleL.copyWith(fontSize: 11, height: 1.2),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static bool _isSvgPath(String pathOrUrl) {
    final lower = pathOrUrl.toLowerCase();
    final path = Uri.tryParse(lower)?.path ?? lower.split('?').first;
    return path.endsWith('.svg');
  }

  Widget _placeholder() => const SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(
      strokeWidth: 1.5,
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF96D4FB)),
    ),
  );

  Widget _errorIcon() =>
      const Icon(Icons.category_outlined, size: 34, color: Colors.grey);

  Widget _buildIcon(String iconPathOrUrl) {
    final cleanPath = iconPathOrUrl.trim();
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return SafeNetworkIcon(
        url: cleanPath,
        width: 34,
        height: 34,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => _placeholder(),
        errorBuilder: (_) => _errorIcon(),
      );
    }

    if (_isSvgPath(cleanPath)) {
      return SvgPicture.asset(
        cleanPath,
        width: 34,
        height: 34,
        errorBuilder: (context, error, stackTrace) => _errorIcon(),
      );
    }

    return Image.asset(
      cleanPath,
      width: 34,
      height: 34,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _errorIcon(),
    );
  }
}
