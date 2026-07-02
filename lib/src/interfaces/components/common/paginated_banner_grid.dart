import 'dart:math';
import 'package:flutter/material.dart';
import '../../../data/models/banner_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../home/banner_section.dart';

List<Widget> buildPaginatedGridSliversWithBanners<T>({
  required List<T> items,
  required Widget Function(BuildContext context, int index, T item) itemBuilder,
  required List<BannerModel> banners,
  required bool hasMore,
  required ScreenSizeData screenSize,
  required double childAspectRatio,
  int crossAxisCount = 2,
  int bannerIndexOffset = 0,
}) {
  if (items.isEmpty) return [];

  final int totalItems = items.length;
  if (banners.isEmpty || totalItems < 10) {
    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(16.0),
        ),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) => itemBuilder(context, index, items[index]),
            childCount: totalItems,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: screenSize.responsivePadding(16.0),
            crossAxisSpacing: screenSize.responsivePadding(16.0),
            childAspectRatio: childAspectRatio,
          ),
        ),
      ),
    ];
  }

  final int totalFullBlocks = totalItems ~/ 10;
  final int chunks = (totalItems + 9) ~/ 10;
  final List<Widget> slivers = [];

  for (int i = 0; i < chunks; i++) {
    final int startIdx = i * 10;
    final int endIdx = min(startIdx + 10, totalItems);
    final int count = endIdx - startIdx;

    slivers.add(
      SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(16.0),
        ),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final itemIdx = startIdx + index;
              return itemBuilder(context, itemIdx, items[itemIdx]);
            },
            childCount: count,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: screenSize.responsivePadding(16.0),
            crossAxisSpacing: screenSize.responsivePadding(16.0),
            childAspectRatio: childAspectRatio,
          ),
        ),
      ),
    );

    final int blockNum = i + 1;
    final int currentBannerIndex = bannerIndexOffset + i;
    bool bannerInserted = false;

    if (blockNum <= totalFullBlocks) {
      final bool isLastChunkInList = (blockNum == totalFullBlocks) && (totalItems == blockNum * 10) && !hasMore;

      if (isLastChunkInList) {
        if (currentBannerIndex < banners.length) {
          final remainingBanners = banners.sublist(currentBannerIndex);
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.responsivePadding(16.0),
                ),
                child: BannerSection(
                  key: ValueKey('banner_carousel_after_${blockNum * 10}'),
                  banners: remainingBanners,
                ),
              ),
            ),
          );
          bannerInserted = true;
        }
      } else {
        if (currentBannerIndex < banners.length) {
          final singleBanner = [banners[currentBannerIndex]];
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.responsivePadding(16.0),
                ),
                child: BannerSection(
                  key: ValueKey('banner_single_after_${blockNum * 10}'),
                  banners: singleBanner,
                ),
              ),
            ),
          );
          bannerInserted = true;
        }
      }
    } else {
      if (totalFullBlocks >= 1 && !hasMore) {
        if (currentBannerIndex < banners.length) {
          final remainingBanners = banners.sublist(currentBannerIndex);
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.responsivePadding(16.0),
                ),
                child: BannerSection(
                  key: ValueKey('banner_carousel_end_$totalItems'),
                  banners: remainingBanners,
                ),
              ),
            ),
          );
          bannerInserted = true;
        }
      }
    }

    if (!bannerInserted && i < chunks - 1) {
      slivers.add(
        SliverToBoxAdapter(
          child: SizedBox(height: screenSize.responsivePadding(16.0)),
        ),
      );
    }
  }

  return slivers;
}
