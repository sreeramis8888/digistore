import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/providers/global_search_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/loading_indicator.dart';
import '../offer_pages/category_offers_page.dart';
import '../partner/product_details_page.dart';
import '../services/service_details_page.dart';

CategoryModel _categoryFromSearchItem(Map<String, dynamic> item) {
  final subs = item['subcategories'];
  return CategoryModel(
    id: (item['_id'] ?? item['id'])?.toString(),
    name: (item['name'] ?? item['category'])?.toString(),
    iconUrl: item['iconUrl']?.toString(),
    subcategories: subs is List
        ? subs.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList()
        : null,
  );
}

Map<String, dynamic> _shopArgsFromSearchItem(Map<String, dynamic> item) {
  return {
    ...item,
    '_id': (item['_id'] ?? item['id'])?.toString(),
    'id': (item['_id'] ?? item['id'])?.toString(),
    'name': item['name']?.toString(),
    'logo': item['logo']?.toString(),
    'serviceCategories': item['serviceCategories'] is List
        ? (item['serviceCategories'] as List)
            .map((e) => e.toString())
            .toList()
        : item['serviceCategories'],
  };
}

class GlobalSearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;

  const GlobalSearchPage({super.key, this.initialQuery});

  @override
  ConsumerState<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends ConsumerState<GlobalSearchPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;
  String _submittedQuery = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery?.trim() ?? '';
    _controller = TextEditingController(text: initial);
    _focusNode = FocusNode();
    _submittedQuery = initial;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit([String? value]) {
    final q = (value ?? _controller.text).trim();
    setState(() => _submittedQuery = q);
    _focusNode.unfocus();
  }

  void _onChanged(String value) {
    // Rebuild immediately so the clear affordance stays in sync while typing.
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final q = value.trim();
      if (q.length >= 2 || q.isEmpty) {
        setState(() => _submittedQuery = q);
      }
    });
  }

  Future<void> _openShop(Map<String, dynamic> item) async {
    final id = (item['_id'] ?? item['id'])?.toString() ?? '';
    if (id.isEmpty) return;

    try {
      final shop = await ref.read(getShopByPartnerIdProvider(id).future);
      if (!mounted) return;
      if (shop != null) {
        Navigator.of(context).pushNamed('shopDetail', arguments: shop);
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pushNamed(
      'shopDetail',
      arguments: ShopModel.fromJson(_shopArgsFromSearchItem(item)),
    );
  }

  void _openOffer(Map<String, dynamic> item) {
    Navigator.of(context).pushNamed(
      'offerDetail',
      arguments: offerArgsFromSearchItem(item),
    );
  }

  void _openService(Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceDetailsPage(
          service: ServiceModel.fromJson(item),
        ),
      ),
    );
  }

  void _openProduct(Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsPage(
          product: productArgsFromSearchItem(item),
        ),
      ),
    );
  }

  void _openCategory(Map<String, dynamic> item) {
    final category = _categoryFromSearchItem(item);
    if ((category.id == null || category.id!.isEmpty) &&
        (category.name == null || category.name!.isEmpty)) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryOffersPage(category: category),
      ),
    );
  }

  void _openViewMore({required String type, required String title}) {
    final q = _submittedQuery.trim();
    if (q.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GlobalSearchListPage(
          query: q,
          type: type,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final query = _submittedQuery.trim();
    final overviewAsync = query.isEmpty
        ? null
        : ref.watch(globalSearchOverviewProvider(query));
    final trendingAsync = query.isEmpty
        ? ref.watch(searchTrendingKeywordsProvider)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF373737),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF6B7280), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onChanged: _onChanged,
                  onSubmitted: _submit,
                  style: kSmallTitleL.copyWith(color: kBlack),
                  decoration: InputDecoration(
                    hintText: 'Search anything',
                    hintStyle: kSmallTitleL.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    setState(() => _submittedQuery = '');
                    _focusNode.requestFocus();
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: query.isEmpty
          ? _buildLanding(trendingAsync, screenSize)
          : overviewAsync!.when(
              loading: () => const Center(child: LoadingAnimation()),
              error: (e, _) => _buildMessage(
                'Could not load results.\n${e.toString()}',
              ),
              data: (overview) {
                if (overview.isEmpty) {
                  return _buildMessage('No results found for "$query"');
                }
                return RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: () async {
                    ref.invalidate(globalSearchOverviewProvider(query));
                    await ref.read(globalSearchOverviewProvider(query).future);
                  },
                  child: ListView(
                    padding: EdgeInsets.only(
                      bottom: screenSize.responsivePadding(32),
                    ),
                    children: [
                      if (overview.categories.isNotEmpty) ...[
                        _sectionHeader(
                          title: 'Categories',
                          count: overview.categoriesCount,
                          onViewMore: overview.categoriesCount >
                                  overview.categories.length
                              ? () => _openViewMore(
                                    type: 'categories',
                                    title: 'Categories',
                                  )
                              : null,
                        ),
                        ...overview.categories.map(
                          (item) => _CategoryResultTile(
                            item: item,
                            onTap: () => _openCategory(item),
                          ),
                        ),
                      ],
                      if (overview.offers.isNotEmpty) ...[
                        _sectionHeader(
                          title: 'Offers',
                          count: overview.offersCount,
                          onViewMore: () => _openViewMore(
                            type: 'offers',
                            title: 'Offers',
                          ),
                        ),
                        ...overview.offers.map(
                          (item) => _OfferResultTile(
                            item: item,
                            onTap: () => _openOffer(item),
                          ),
                        ),
                      ],
                      if (overview.shops.isNotEmpty) ...[
                        _sectionHeader(
                          title: 'Shops',
                          count: overview.shopsCount,
                          onViewMore: () => _openViewMore(
                            type: 'shops',
                            title: 'Shops',
                          ),
                        ),
                        ...overview.shops.map(
                          (item) => _ShopResultTile(
                            item: item,
                            onTap: () => _openShop(item),
                          ),
                        ),
                      ],
                      if (overview.services.isNotEmpty) ...[
                        _sectionHeader(
                          title: 'Services',
                          count: overview.servicesCount,
                          onViewMore: () => _openViewMore(
                            type: 'services',
                            title: 'Services',
                          ),
                        ),
                        ...overview.services.map(
                          (item) => _ServiceResultTile(
                            item: item,
                            onTap: () => _openService(item),
                          ),
                        ),
                      ],
                      if (overview.products.isNotEmpty) ...[
                        _sectionHeader(
                          title: 'Products',
                          count: overview.productsCount,
                          onViewMore: () => _openViewMore(
                            type: 'products',
                            title: 'Products',
                          ),
                        ),
                        ...overview.products.map(
                          (item) => _ProductResultTile(
                            item: item,
                            onTap: () => _openProduct(item),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLanding(
    AsyncValue<List<String>>? trendingAsync,
    ScreenSizeData screenSize,
  ) {
    return ListView(
      padding: EdgeInsets.all(screenSize.responsivePadding(20)),
      children: [
        Text(
          'Search everything',
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Find offers, shops, services, products, and categories.',
          style: GoogleFonts.urbanist(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 24),
        if (trendingAsync != null)
          trendingAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (keywords) {
              if (keywords.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trending',
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: keywords.take(10).map((kw) {
                      return ActionChip(
                        label: Text(kw),
                        backgroundColor: kWhite,
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        labelStyle: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                        onPressed: () {
                          _controller.text = kw;
                          _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: kw.length),
                          );
                          _submit(kw);
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _sectionHeader({
    required String title,
    required int count,
    VoidCallback? onViewMore,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              count > 0 ? '$title ($count)' : title,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          if (onViewMore != null)
            TextButton(
              onPressed: onViewMore,
              child: Text(
                'View more',
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            color: const Color(0xFF6B7280),
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/// Full paginated list for a search type ("View more").
class GlobalSearchListPage extends ConsumerStatefulWidget {
  final String query;
  final String type;
  final String title;

  const GlobalSearchListPage({
    super.key,
    required this.query,
    required this.type,
    required this.title,
  });

  @override
  ConsumerState<GlobalSearchListPage> createState() =>
      _GlobalSearchListPageState();
}

class _GlobalSearchListPageState extends ConsumerState<GlobalSearchListPage> {
  final ScrollController _scrollController = ScrollController();
  GlobalSearchPaged? _paged;
  bool _loadingMore = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || _paged == null || !_paged!.hasMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _paged == null || !_paged!.hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final next = await fetchGlobalSearchPage(
        ref,
        query: widget.query,
        type: widget.type,
        page: _paged!.page + 1,
        previous: _paged,
      );
      if (!mounted) return;
      setState(() {
        _paged = next;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _openShop(Map<String, dynamic> item) async {
    final id = (item['_id'] ?? item['id'])?.toString() ?? '';
    if (id.isEmpty) return;
    try {
      final shop = await ref.read(getShopByPartnerIdProvider(id).future);
      if (!mounted) return;
      if (shop != null) {
        Navigator.of(context).pushNamed('shopDetail', arguments: shop);
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushNamed(
      'shopDetail',
      arguments: ShopModel.fromJson(_shopArgsFromSearchItem(item)),
    );
  }

  void _openOffer(Map<String, dynamic> item) {
    Navigator.of(context).pushNamed(
      'offerDetail',
      arguments: offerArgsFromSearchItem(item),
    );
  }

  void _openService(Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceDetailsPage(
          service: ServiceModel.fromJson(item),
        ),
      ),
    );
  }

  void _openProduct(Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsPage(
          product: productArgsFromSearchItem(item),
        ),
      ),
    );
  }

  void _openCategory(Map<String, dynamic> item) {
    final category = _categoryFromSearchItem(item);
    if ((category.id == null || category.id!.isEmpty) &&
        (category.name == null || category.name!.isEmpty)) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryOffersPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = (query: widget.query, type: widget.type);
    final async = ref.watch(globalSearchPagedProvider(args));

    ref.listen(globalSearchPagedProvider(args), (prev, next) {
      next.whenData((data) {
        if (!_initialized && mounted) {
          setState(() {
            _paged = data;
            _initialized = true;
          });
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF373737),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.title} for "${widget.query}"',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: async.when(
        loading: () => const Center(child: LoadingAnimation()),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: GoogleFonts.urbanist(color: const Color(0xFF6B7280)),
          ),
        ),
        data: (initial) {
          final paged = _paged ?? initial;
          if (paged.results.isEmpty) {
            return Center(
              child: Text(
                'No ${widget.title.toLowerCase()} found',
                style: GoogleFonts.urbanist(color: const Color(0xFF6B7280)),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: paged.results.length + (_loadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= paged.results.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: LoadingAnimation()),
                );
              }
              final item = paged.results[index];
              switch (widget.type) {
                case 'offers':
                  return _OfferResultTile(
                    item: item,
                    onTap: () => _openOffer(item),
                  );
                case 'services':
                  return _ServiceResultTile(
                    item: item,
                    onTap: () => _openService(item),
                  );
                case 'products':
                  return _ProductResultTile(
                    item: item,
                    onTap: () => _openProduct(item),
                  );
                case 'categories':
                  return _CategoryResultTile(
                    item: item,
                    onTap: () => _openCategory(item),
                  );
                default:
                  return _ShopResultTile(
                    item: item,
                    onTap: () => _openShop(item),
                  );
              }
            },
          );
        },
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? meta;
  final String? imageUrl;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.title,
    required this.onTap,
    required this.fallbackIcon,
    this.subtitle,
    this.meta,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? AdvancedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            disableFade: true,
                          )
                        : Container(
                            color: const Color(0xFFF3F5F4),
                            child: Icon(
                              fallbackIcon,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                      if (meta != null && meta!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          meta!,
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _distanceLabel(dynamic distance) {
  if (distance is! num) return null;
  return '${distance.toStringAsFixed(1)} km';
}

String? _firstImage(dynamic images) {
  if (images is! List || images.isEmpty) return null;
  return images.first.toString();
}

class _OfferResultTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _OfferResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final partner = item['partner'];
    final shopName =
        partner is Map ? partner['name']?.toString() ?? '' : '';
    final image = (item['bannerImage'] ?? _firstImage(item['images']))
        ?.toString();

    return _SearchResultTile(
      title: item['title']?.toString() ?? 'Offer',
      subtitle: shopName,
      meta: _distanceLabel(item['distance']),
      imageUrl: image,
      fallbackIcon: Icons.local_offer_outlined,
      onTap: onTap,
    );
  }
}

class _ShopResultTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _ShopResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final logo = item['logo']?.toString();
    final cover = _firstImage(item['images']) ?? logo;

    return _SearchResultTile(
      title: item['name']?.toString() ?? 'Shop',
      subtitle: item['category']?.toString() ?? '',
      meta: _distanceLabel(item['distance']),
      imageUrl: cover,
      fallbackIcon: Icons.storefront,
      onTap: onTap,
    );
  }
}

class _ServiceResultTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _ServiceResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final partner = item['partner'];
    final shopName =
        partner is Map ? partner['name']?.toString() ?? '' : '';
    final price = item['effectivePrice'] ?? item['offerPrice'] ?? item['price'];
    final priceLabel = price is num ? '₹ ${price.toInt()}' : null;
    final distance = _distanceLabel(item['distance']);
    final meta = [
      ?priceLabel,
      ?distance,
    ].join(' · ');

    return _SearchResultTile(
      title: item['name']?.toString() ?? 'Service',
      subtitle: [
        if ((item['category']?.toString() ?? '').isNotEmpty)
          item['category'].toString(),
        if (shopName.isNotEmpty) shopName,
      ].join(' · '),
      meta: meta.isEmpty ? null : meta,
      imageUrl: _firstImage(item['images']),
      fallbackIcon: Icons.content_cut_rounded,
      onTap: onTap,
    );
  }
}

class _ProductResultTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _ProductResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final partner = item['partner'];
    final shopName =
        partner is Map ? partner['name']?.toString() ?? '' : '';
    final price = item['effectivePrice'] ?? item['offerPrice'] ?? item['price'];
    final priceLabel = price is num ? '₹ ${price.toInt()}' : null;

    return _SearchResultTile(
      title: (item['title'] ?? item['name'])?.toString() ?? 'Product',
      subtitle: shopName,
      meta: priceLabel,
      imageUrl: _firstImage(item['images']),
      fallbackIcon: Icons.shopping_bag_outlined,
      onTap: onTap,
    );
  }
}

class _CategoryResultTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _CategoryResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final subs = item['subcategories'];
    final subLabel = subs is List && subs.isNotEmpty
        ? subs.take(3).map((e) => e.toString()).join(', ')
        : '';

    return _SearchResultTile(
      title: (item['name'] ?? item['category'])?.toString() ?? 'Category',
      subtitle: subLabel,
      imageUrl: item['iconUrl']?.toString(),
      fallbackIcon: Icons.grid_view_rounded,
      onTap: onTap,
    );
  }
}
