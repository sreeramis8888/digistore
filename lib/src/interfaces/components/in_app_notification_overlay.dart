import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'advanced_network_image.dart';

class InAppNotificationOverlay {
  static OverlayEntry? _currentOverlay;
  static Timer? _dismissTimer;

  static bool _wasInteracted = false;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? imageUrl,
    Widget? leadingWidget,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    VoidCallback? onTimeout,
    Color accentColor = const Color(0xFF1E3A81),
    OverlayState? overlayState,
  }) {
    dismiss();
    _wasInteracted = false;

    final overlay = overlayState ?? Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (_) => _InAppNotificationWidget(
        title: title,
        message: message,
        imageUrl: imageUrl,
        leadingWidget: leadingWidget,
        accentColor: accentColor,
        onTap: () {
          _wasInteracted = true;
          dismiss();
          onTap?.call();
        },
        onDismiss: () {
          _wasInteracted = true;
          dismiss();
        },
      ),
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);

    _dismissTimer = Timer(duration, () {
      if (!_wasInteracted) {
        onTimeout?.call();
      }
      dismiss();
    });
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _InAppNotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? imageUrl;
  final Widget? leadingWidget;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final Color accentColor;

  const _InAppNotificationWidget({
    required this.title,
    required this.message,
    this.imageUrl,
    this.leadingWidget,
    required this.onTap,
    required this.onDismiss,
    required this.accentColor,
  });

  @override
  State<_InAppNotificationWidget> createState() =>
      _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<_InAppNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 400),
    );

    _slide = Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const ElasticOutCurve(0.8),
            reverseCurve: Curves.easeInBack,
          ),
        );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const ElasticOutCurve(0.8)),
    );

    _controller.forward();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 16,
      right: 16,
      child: SafeArea(
        child: SlideTransition(
          position: _slide,
          child: ScaleTransition(
            scale: _scale,
            child: FadeTransition(
              opacity: _fade,
              child: Material(
                type: MaterialType.transparency,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: GestureDetector(
                      onTap: widget.onTap,
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity != null &&
                            details.primaryVelocity! < 0) {
                          _dismiss();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF141417), // Deep premium dark
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: widget.accentColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withOpacity(0.25),
                              blurRadius: 40,
                              offset: const Offset(0, 15),
                              spreadRadius: -5,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildLeading(),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.title,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.2,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  widget.accentColor,
                                                  widget.accentColor.withOpacity(0.7),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'NEW',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.8,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (widget.message.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          widget.message,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            height: 1.3,
                                            color: Color(0xFFA1A1AA), // Soft silver
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white70,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    if (widget.leadingWidget != null) return widget.leadingWidget!;

    if (widget.imageUrl != null) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26), // Circle inside pill
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: AdvancedNetworkImage(
            imageUrl: widget.imageUrl!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Colors.white,
            Color(0xFFE2E8F0), // Cool silver
          ],
          center: Alignment.topLeft,
          radius: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 0),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.notifications_active_rounded,
          color: widget.accentColor,
          size: 24,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
