import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/business_info.dart';

class ShopFaqs extends ConsumerStatefulWidget {
  final List<BusinessFAQ>? faqs;

  const ShopFaqs({super.key, this.faqs});

  @override
  ConsumerState<ShopFaqs> createState() => _ShopFaqsState();
}

class _ShopFaqsState extends ConsumerState<ShopFaqs> {
  final Set<int> _expandedIndices = {};

  @override
  Widget build(BuildContext context) {
    final faqs = widget.faqs?.where((f) => f.question?.isNotEmpty == true).toList() ?? [];
    if (faqs.isEmpty) return const SizedBox.shrink();

    final screenSize = ref.watch(screenSizeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequently Asked Questions', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: faqs.length,
          separatorBuilder: (_, __) => SizedBox(height: screenSize.responsivePadding(8)),
          itemBuilder: (context, index) {
            final faq = faqs[index];
            final isExpanded = _expandedIndices.contains(index);

            return Container(
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedIndices.remove(index);
                    } else {
                      _expandedIndices.add(index);
                    }
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(14),
                    vertical: screenSize.responsivePadding(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq.question ?? '',
                              style: kSmallTitleM.copyWith(
                                color: kTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: EdgeInsets.only(top: screenSize.responsivePadding(8)),
                          child: Text(
                            faq.answer ?? '',
                            style: kSmallerTitleL.copyWith(
                              color: kSecondaryTextColor,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
