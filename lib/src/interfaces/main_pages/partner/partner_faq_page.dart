import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/business_info.dart';
import '../../../data/models/partner_model.dart';
import '../../../data/providers/partner_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/services/snackbar_service.dart';
import '../../components/confirmation_dialog.dart';
import '../../components/partner/add_faq_dialog.dart';

class PartnerFaqPage extends ConsumerStatefulWidget {
  const PartnerFaqPage({super.key});

  @override
  ConsumerState<PartnerFaqPage> createState() => _PartnerFaqPageState();
}

class _PartnerFaqPageState extends ConsumerState<PartnerFaqPage> {
  static const _bg = Color(0xFFF3F5F4);
  static const _accent = Color(0xFF6155F5);

  final Set<int> _expanded = {};
  bool _isSaving = false;
  List<BusinessFAQ> _faqs = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _syncFromPartner();
    }
  }

  void _syncFromPartner() {
    final partner = ref.read(partnerProvider);
    _faqs = List<BusinessFAQ>.from(partner?.businessInfo?.faqs ?? []);
  }

  BusinessInfo _withFaqs(BusinessInfo? info, List<BusinessFAQ> faqs) {
    return BusinessInfo(
      businessLogo: info?.businessLogo,
      coverImage: info?.coverImage,
      businessImages: info?.businessImages,
      description: info?.description,
      tagline: info?.tagline,
      specialties: info?.specialties,
      yearsOfExperience: info?.yearsOfExperience,
      rating: info?.rating,
      totalReviews: info?.totalReviews,
      contactPhone: info?.contactPhone,
      otpPhone: info?.otpPhone,
      whatsappNumber: info?.whatsappNumber,
      websiteUrl: info?.websiteUrl,
      operatingHours: info?.operatingHours,
      socialLinks: info?.socialLinks,
      videoUrl: info?.videoUrl,
      achievements: info?.achievements,
      faqs: faqs,
      branches: info?.branches,
      ownerName: info?.ownerName,
      email: info?.email,
    );
  }

  PartnerModel? _partnerWithFaqs(List<BusinessFAQ> faqs) {
    final current = ref.read(partnerProvider);
    if (current == null) return null;
    return PartnerModel(
      id: current.id,
      userId: current.userId,
      businessDetails: current.businessDetails,
      businessInfo: _withFaqs(current.businessInfo, faqs),
      coverageAreas: current.coverageAreas,
      serviceCategories: current.serviceCategories,
      incomeSharingPercentage: current.incomeSharingPercentage,
      verificationStatus: current.verificationStatus,
      isActive: current.isActive,
      isFeatured: current.isFeatured,
      isPremium: current.isPremium,
      tags: current.tags,
      totalLeads: current.totalLeads,
      convertedLeads: current.convertedLeads,
      totalRevenue: current.totalRevenue,
      paymentDetails: current.paymentDetails,
      documents: current.documents,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      devices: current.devices,
    );
  }

  Future<bool> _persist(List<BusinessFAQ> faqs) async {
    final updated = _partnerWithFaqs(faqs);
    if (updated == null) return false;
    setState(() => _isSaving = true);
    final ok = await ref.read(partnerProvider.notifier).updateProfile(updated);
    if (mounted) {
      setState(() {
        _isSaving = false;
        if (ok) {
          _faqs = List<BusinessFAQ>.from(
            ref.read(partnerProvider)?.businessInfo?.faqs ?? faqs,
          );
        }
      });
    }
    return ok;
  }

  Future<void> _addOrEdit({int? index}) async {
    final initial = index != null ? _faqs[index] : null;
    final result = await showAddFaqDialog(context, initialFaq: initial);
    if (result == null || !mounted) return;

    final next = List<BusinessFAQ>.from(_faqs);
    if (index != null) {
      next[index] = result;
    } else {
      next.add(result);
    }

    final ok = await _persist(next);
    if (!mounted) return;
    SnackbarService().showSnackBar(
      context,
      ok
          ? (index != null ? 'FAQ updated' : 'FAQ added')
          : 'Failed to save FAQ',
      type: ok ? SnackbarType.success : SnackbarType.error,
    );
  }

  Future<void> _delete(int index) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete FAQ',
      message: 'Are you sure you want to delete this FAQ?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed != true || !mounted) return;

    final next = List<BusinessFAQ>.from(_faqs)..removeAt(index);
    final ok = await _persist(next);
    if (!mounted) return;
    setState(() {
      _expanded.remove(index);
      _expanded.removeWhere((i) => i >= next.length);
    });
    SnackbarService().showSnackBar(
      context,
      ok ? 'FAQ deleted' : 'Failed to delete FAQ',
      type: ok ? SnackbarType.success : SnackbarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF373737),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'FAQ',
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF373737),
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _accent,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : () => _addOrEdit(),
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Add FAQ',
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _faqs.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(screenSize.responsivePadding(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 32,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No FAQs yet',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add questions customers often ask about your shop.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                screenSize.responsivePadding(16),
                8,
                screenSize.responsivePadding(16),
                100,
              ),
              itemCount: _faqs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                final expanded = _expanded.contains(index);
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (expanded) {
                            _expanded.remove(index);
                          } else {
                            _expanded.add(index);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    faq.question ?? '',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedRotation(
                                  turns: expanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 22,
                                    color: Color(0xFF99A1AF),
                                  ),
                                ),
                              ],
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      faq.answer ?? '',
                                      style: GoogleFonts.urbanist(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        _actionChip(
                                          icon: Icons.edit_outlined,
                                          label: 'Edit',
                                          onTap: _isSaving
                                              ? null
                                              : () => _addOrEdit(index: index),
                                        ),
                                        const SizedBox(width: 8),
                                        _actionChip(
                                          icon: Icons.delete_outline_rounded,
                                          label: 'Delete',
                                          destructive: true,
                                          onTap: _isSaving
                                              ? null
                                              : () => _delete(index),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              crossFadeState: expanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 200),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool destructive = false,
  }) {
    final color =
        destructive ? const Color(0xFFFF383C) : const Color(0xFF6155F5);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
