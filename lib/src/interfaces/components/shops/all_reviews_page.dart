import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';
import '../../../../src/data/models/review_model.dart';
import '../../../../src/data/providers/reviews_provider.dart';
import '../../../../src/data/providers/api_provider.dart';
import '../advanced_network_image.dart';
import '../full_screen_gallery.dart';
import '../loading_indicator.dart';
import './add_review_sheet.dart';

class ShopAllReviewsState {
  final List<ReviewModel> reviews;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final bool hasMore;
  final int totalReviews;

  ShopAllReviewsState({
    this.reviews = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
    this.totalReviews = 0,
  });

  ShopAllReviewsState copyWith({
    List<ReviewModel>? reviews,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    bool? hasMore,
    int? totalReviews,
  }) {
    return ShopAllReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }
}

class ShopAllReviewsNotifier extends StateNotifier<ShopAllReviewsState> {
  final Ref ref;
  final String shopId;

  ShopAllReviewsNotifier(this.ref, this.shopId) : super(ShopAllReviewsState()) {
    fetchReviews(refresh: true);
  }

  Future<void> fetchReviews({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, page: 1, hasMore: true, error: null);
    } else {
      if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final api = ref.read(apiProvider);
      final currentPage = refresh ? 1 : state.page;
      final response = await api.get('/reviews/shop/$shopId?page=$currentPage&limit=15');

      if (response.success && response.data != null) {
        final paginated = PaginatedReviews.fromJson(response.data!);
        final newReviews = paginated.reviews;
        final allReviews = refresh ? newReviews : [...state.reviews, ...newReviews];

        state = state.copyWith(
          reviews: allReviews,
          page: currentPage + 1,
          hasMore: paginated.page < paginated.pages && newReviews.isNotEmpty,
          isLoading: false,
          isLoadingMore: false,
          totalReviews: paginated.total > 0 ? paginated.total : allReviews.length,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          hasMore: false,
          error: response.message ?? 'Failed to fetch reviews',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void addReviewLocally(ReviewModel review) {
    state = state.copyWith(
      reviews: [review, ...state.reviews],
      totalReviews: state.totalReviews + 1,
    );
  }
}

final shopAllReviewsProvider =
    StateNotifierProvider.family<ShopAllReviewsNotifier, ShopAllReviewsState, String>(
  (ref, shopId) => ShopAllReviewsNotifier(ref, shopId),
);

class AllReviewsPage extends ConsumerStatefulWidget {
  final ShopModel shop;

  const AllReviewsPage({super.key, required this.shop});

  @override
  ConsumerState<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends ConsumerState<AllReviewsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final shopId = widget.shop.id;
      if (shopId != null) {
        ref.read(shopAllReviewsProvider(shopId).notifier).fetchReviews();
      }
    }
  }

  void _openAddReviewSheet() async {
    final shopId = widget.shop.id;
    if (shopId == null) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReviewSheet(shop: widget.shop),
    );

    if (result == true) {
      ref.read(shopAllReviewsProvider(shopId).notifier).fetchReviews(refresh: true);
      ref.invalidate(reviewsProvider(shopId: shopId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final shopId = widget.shop.id ?? '';
    final reviewsState = ref.watch(shopAllReviewsProvider(shopId));
    final rating = widget.shop.businessInfo?.rating ?? 0.0;

    final displayedReviews = reviewsState.reviews;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Customer Reviews', style: kBodyTitleSB),
        actions: [
          TextButton.icon(
            onPressed: _openAddReviewSheet,
            icon: const Icon(Icons.edit_rounded, color: kPrimaryColor, size: 16),
            label: Text(
              'Review',
              style: kSmallTitleSB.copyWith(color: kPrimaryColor),
            ),
          ),
          SizedBox(width: screenSize.responsivePadding(8)),
        ],
      ),
      body: reviewsState.isLoading && reviewsState.reviews.isEmpty
          ? const Center(child: LoadingAnimation())
          : RefreshIndicator(
              color: kPrimaryColor,
              onRefresh: () => ref.read(shopAllReviewsProvider(shopId).notifier).fetchReviews(refresh: true),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                      child: Column(
                        children: [
                          _buildRatingOverviewCard(screenSize, rating, reviewsState.totalReviews),
                        ],
                      ),
                    ),
                  ),
                  if (reviewsState.error != null && reviewsState.reviews.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                            SizedBox(height: screenSize.responsivePadding(12)),
                            Text('Could not load reviews', style: kBodyTitleM),
                            SizedBox(height: screenSize.responsivePadding(8)),
                            ElevatedButton(
                              onPressed: () => ref.read(shopAllReviewsProvider(shopId).notifier).fetchReviews(refresh: true),
                              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                              child: const Text('Retry', style: TextStyle(color: kWhite)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (displayedReviews.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review_outlined, color: kSecondaryTextColor.withValues(alpha: 0.5), size: 56),
                            SizedBox(height: screenSize.responsivePadding(16)),
                            Text(
                              'No reviews yet',
                              style: kBodyTitleM.copyWith(color: kSecondaryTextColor),
                            ),
                            SizedBox(height: screenSize.responsivePadding(16)),
                            ElevatedButton.icon(
                              onPressed: _openAddReviewSheet,
                              icon: const Icon(Icons.star_outline_rounded, color: kWhite, size: 18),
                              label: const Text('Be the first to review', style: TextStyle(color: kWhite)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.responsivePadding(20),
                                  vertical: screenSize.responsivePadding(12),
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == displayedReviews.length) {
                              if (reviewsState.isLoadingMore) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: screenSize.responsivePadding(24)),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: kPrimaryColor),
                                    ),
                                  ),
                                );
                              } else if (!reviewsState.hasMore) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: screenSize.responsivePadding(32)),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle_outline_rounded, size: 16, color: kSecondaryTextColor.withValues(alpha: 0.6)),
                                        SizedBox(width: screenSize.responsivePadding(6)),
                                        Text(
                                          "You've reached the end of reviews",
                                          style: kSmallTitleR.copyWith(
                                            color: kSecondaryTextColor.withValues(alpha: 0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }

                            final review = displayedReviews[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: screenSize.responsivePadding(16)),
                              child: _VerticalReviewCard(
                                review: review,
                                screenSize: screenSize,
                              ),
                            );
                          },
                          childCount: displayedReviews.length + 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildRatingOverviewCard(ScreenSizeData screenSize, double rating, int totalReviews) {
    return Container(
      padding: EdgeInsets.all(screenSize.responsivePadding(20)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F3F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B2A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                rating > 0 ? rating.toStringAsFixed(1) : '5.0',
                style: kLargeTitleB.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: kTextColor,
                  height: 1.0,
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(6)),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFFC107),
                    size: 18,
                  );
                }),
              ),
              SizedBox(height: screenSize.responsivePadding(4)),
              Text(
                '$totalReviews Verified Reviews',
                style: kSmallTitleR.copyWith(
                  color: kSecondaryTextColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          SizedBox(width: screenSize.responsivePadding(20)),
          Container(
            width: 1,
            height: screenSize.responsivePadding(65),
            color: const Color(0xFFEEEEEE),
          ),
          SizedBox(width: screenSize.responsivePadding(20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 16),
                    ),
                    SizedBox(width: screenSize.responsivePadding(8)),
                    Expanded(
                      child: Text(
                        '100% Verified Customer Feedback',
                        style: kSmallTitleSB.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenSize.responsivePadding(12)),
                Text(
                  'Reviews are submitted by genuine Setgo members who have experienced this business.',
                  style: kSmallTitleR.copyWith(
                    fontSize: 11,
                    color: kSecondaryTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalReviewCard extends StatelessWidget {
  final ReviewModel review;
  final ScreenSizeData screenSize;

  const _VerticalReviewCard({required this.review, required this.screenSize});

  void _showFullImageGallery(BuildContext context, List<String> imageUrls, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenGallery(
            images: imageUrls,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFFFB74D),
      const Color(0xFF64B5F6),
      const Color(0xFF81C784),
      const Color(0xFFBA68C8),
      const Color(0xFF4DB6AC),
    ];
    final color = colors[review.userName.hashCode.abs() % colors.length];
    final hasImages = review.images != null && review.images!.isNotEmpty;
    final rating = review.rating ?? 5.0;

    return Container(
      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B2A).withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: screenSize.responsivePadding(20),
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Text(
                      (review.userName ?? 'U')[0].toUpperCase(),
                      style: kSmallTitleB.copyWith(color: color, fontSize: 16),
                    ),
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName ?? 'Setgo Member',
                        style: kSmallTitleSB.copyWith(
                          fontSize: 14,
                          color: kTextColor,
                        ),
                      ),
                      SizedBox(height: screenSize.responsivePadding(2)),
                      Text(
                        'Verified Customer',
                        style: kSmallTitleR.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(10),
                  vertical: screenSize.responsivePadding(5),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: kSmallTitleSB.copyWith(
                        color: const Color(0xFFF57F17),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: screenSize.responsivePadding(4)),
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: screenSize.responsivePadding(14)),
            Text(
              review.comment!,
              style: kSmallTitleR.copyWith(
                color: kTextColor.withValues(alpha: 0.85),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
          if (hasImages) ...[
            SizedBox(height: screenSize.responsivePadding(14)),
            SizedBox(
              height: screenSize.responsivePadding(72),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: review.images!.length,
                separatorBuilder: (context, index) =>
                    SizedBox(width: screenSize.responsivePadding(10)),
                itemBuilder: (context, index) {
                  final imageUrl = review.images![index];
                  return Hero(
                    tag: 'vertical_review_${review.id ?? index}_$index',
                    child: GestureDetector(
                      onTap: () => _showFullImageGallery(context, review.images!, index),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                        ),
                        child: AdvancedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12),
                          width: screenSize.responsivePadding(72),
                          height: screenSize.responsivePadding(72),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
