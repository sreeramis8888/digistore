import '../models/offer_model.dart';

/// Helper utility for resolving offer effective status and liveliness.
/// Mirrors backend `resolveOfferDisplayStatus` to ensure partner and admin
/// agree on one effective status per offer.
class OfferStatusUtils {
  OfferStatusUtils._();

  /// Resolves the display/effective status of an offer based on:
  /// - workflow `status`
  /// - visibility `isActive`
  /// - expiration date `validTo`
  ///
  /// Never defaults missing status to 'active'.
  static String resolveDisplayStatus({
    String? status,
    bool? isActive,
    DateTime? validTo,
    DateTime? now,
  }) {
    final rawStatus = status?.toLowerCase().trim();
    if (rawStatus == null || rawStatus.isEmpty) {
      return 'draft';
    }

    if (rawStatus == 'active') {
      final currentTime = now ?? DateTime.now();
      if (validTo != null && validTo.isBefore(currentTime)) {
        return 'expired';
      }
      if (isActive == false) {
        return 'paused';
      }
    }

    return rawStatus;
  }

  /// Convenience resolver from an [OfferModel].
  static String resolveOfferStatus(OfferModel? offer, {DateTime? now}) {
    if (offer == null) return 'draft';
    return resolveDisplayStatus(
      status: offer.status,
      isActive: offer.isActive,
      validTo: offer.validTo,
      now: now,
    );
  }

  /// Convenience resolver from raw navigation / API arguments map.
  static String resolveMapStatus(Map<String, dynamic>? map, {DateTime? now}) {
    if (map == null) return 'draft';

    final rawStatus = map['displayStatus'] ?? map['status'];
    final rawIsActive = map['isActive'];
    bool? isActive;
    if (rawIsActive is bool) {
      isActive = rawIsActive;
    } else if (rawIsActive is String) {
      isActive = rawIsActive.toLowerCase() == 'true';
    }

    DateTime? validTo;
    final rawValidTo = map['validTo'];
    if (rawValidTo is DateTime) {
      validTo = rawValidTo;
    } else if (rawValidTo is String && rawValidTo.isNotEmpty) {
      validTo = DateTime.tryParse(rawValidTo)?.toLocal();
    }

    return resolveDisplayStatus(
      status: rawStatus?.toString(),
      isActive: isActive,
      validTo: validTo,
      now: now,
    );
  }

  /// Returns true ONLY if the offer is genuinely active/live for redemption:
  /// - resolved status == 'active'
  /// - isActive != false
  /// - validTo >= now (if present)
  /// - validFrom <= now (if present)
  static bool isLiveForPartner({
    String? status,
    bool? isActive,
    DateTime? validFrom,
    DateTime? validTo,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final effectiveStatus = resolveDisplayStatus(
      status: status,
      isActive: isActive,
      validTo: validTo,
      now: currentTime,
    );

    if (effectiveStatus != 'active') {
      return false;
    }

    if (isActive == false) {
      return false;
    }

    if (validFrom != null && validFrom.isAfter(currentTime)) {
      return false;
    }

    if (validTo != null && validTo.isBefore(currentTime)) {
      return false;
    }

    return true;
  }

  /// Checks liveliness directly on an [OfferModel].
  static bool isOfferLive(OfferModel? offer, {DateTime? now}) {
    if (offer == null) return false;
    return isLiveForPartner(
      status: offer.status,
      isActive: offer.isActive,
      validFrom: offer.validFrom,
      validTo: offer.validTo,
      now: now,
    );
  }
}
