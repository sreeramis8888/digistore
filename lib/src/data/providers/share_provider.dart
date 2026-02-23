import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:digistore/src/data/services/deep_link_service.dart';

final shareProviderProvider = Provider<ShareService>((ref) {
  final deepLinkService = ref.watch(deepLinkServiceProvider);
  return ShareService(deepLinkService);
});

class ShareService {
  final DeepLinkService _deepLinkService;

  ShareService(this._deepLinkService);

  /// Share a feed with deep link
  Future<ShareResult> shareFeed({
    required String feedId,
    required String feedTitle,
    String? feedDescription,
  }) async {
    try {
      // Generate deep link for the feed
      final deepLink = _deepLinkService.generateDeepLink('feed', id: feedId);

      // Create share text with title and link
      final shareText = feedDescription != null
          ? '$feedTitle\n\n$feedDescription\n\n$deepLink'
          : '$feedTitle\n\n$deepLink';

      final params = ShareParams(
        text: shareText,
        title: 'Share Feed',
      );

      final result = await SharePlus.instance.share(params);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Share a campaign with deep link
  Future<ShareResult> shareCampaign({
    required String campaignId,
    required String campaignTitle,
    String? campaignDescription,
  }) async {
    try {
      final deepLink = _deepLinkService.generateDeepLink('campaign', id: campaignId);

      final shareText = campaignDescription != null
          ? '$campaignTitle\n\n$campaignDescription\n\n$deepLink'
          : '$campaignTitle\n\n$deepLink';

      final params = ShareParams(
        text: shareText,
        title: 'Share Campaign',
      );

      final result = await SharePlus.instance.share(params);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Share a resource with deep link
  Future<ShareResult> shareResource({
    required String resourceId,
    required String resourceTitle,
    String? resourceDescription,
  }) async {
    try {
      final deepLink = _deepLinkService.generateDeepLink('resource', id: resourceId);

      final shareText = resourceDescription != null
          ? '$resourceTitle\n\n$resourceDescription\n\n$deepLink'
          : '$resourceTitle\n\n$deepLink';

      final params = ShareParams(
        text: shareText,
        title: 'Share Resource',
      );

      final result = await SharePlus.instance.share(params);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Share an event with deep link
  Future<ShareResult> shareEvent({
    required String eventId,
    required String eventTitle,
    String? eventDescription,
  }) async {
    try {
      final deepLink = _deepLinkService.generateDeepLink('event', id: eventId);

      final shareText = eventDescription != null
          ? '$eventTitle\n\n$eventDescription\n\n$deepLink'
          : '$eventTitle\n\n$deepLink';

      final params = ShareParams(
        text: shareText,
        title: 'Share Event',
      );

      final result = await SharePlus.instance.share(params);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Share referral code with app links
  Future<ShareResult> shareReferral({
    required String referralCode,
    required String androidLink,
    required String iosLink,
  }) async {
    try {
      final shareText = 'Join Million Malayali Club! Use my referral code: $referralCode\n\nDownload the app:\nAndroid: $androidLink\niOS: $iosLink';

      final params = ShareParams(
        text: shareText,
        title: 'Invite Friends',
      );

      final result = await SharePlus.instance.share(params);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
