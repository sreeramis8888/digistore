import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';

/// Underline category filters matching Digistore-Pay Products & Services.
class ServicesFilterChips extends ConsumerStatefulWidget {
  const ServicesFilterChips({super.key});

  @override
  ConsumerState<ServicesFilterChips> createState() =>
      _ServicesFilterChipsState();
}

class _ServicesFilterChipsState extends ConsumerState<ServicesFilterChips> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _keys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedIndex(int index) {
    final keyContext = _keys[index]?.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final selectedIndex = ref.watch(selectedServicesCategoryProvider);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        final filters = ['All', ...categories];

        return SizedBox(
          height: 27,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16),
            ),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final isSelected = index == selectedIndex;
              final filterName = filters[index];
              _keys[index] ??= GlobalKey();

              return InteractiveFeedbackButton(
                onPressed: () {
                  ref.read(selectedServicesCategoryProvider.notifier).state =
                      index;
                  final categoryToFetch = index == 0 ? null : filterName;
                  ref
                      .read(servicesListProvider.notifier)
                      .updateCategory(categoryToFetch);
                  _scrollToSelectedIndex(index);
                },
                scaleFactor: 0.97,
                child: Container(
                  key: _keys[index],
                  margin: EdgeInsets.only(
                    right: screenSize.responsivePadding(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        filterName,
                        style: (isSelected ? kSmallTitleSB : kSmallTitleL)
                            .copyWith(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFF111827)
                              : const Color(0xFF6B7280),
                          height: 1.2,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isSelected ? 24 : 0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3576FF),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 27),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
