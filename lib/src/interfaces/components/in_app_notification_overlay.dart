import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'advanced_network_image.dart';

class InAppNotificationOverlay {
  static OverlayEntry? _currentOverlay;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? imageUrl,
    Widget? leadingWidget,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    Color accentColor = const Color(0xFF1E3A81),
    OverlayState? overlayState,
  }) {
    dismiss();

    final overlay = overlayState ?? Overlay.of(context);
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (_) => _InAppNotificationWidget(
        title: title,
        message: message,
        imageUrl: imageUrl,
        leadingWidget: leadingWidget,
        accentColor: accentColor,
        onTap: () {
          dismiss();
          onTap?.call();
        },
        onDismiss: dismiss,
      ),
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);

    _dismissTimer = Timer(duration, dismiss);
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                10,
                                10,
                                16,
                                10,
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildLeading(),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  widget.title,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: -0.2,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                'Now',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (widget.message.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              widget.message,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                height: 1.25,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
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
        ),
      ),
    );
  }

  Widget _buildLeading() {
    if (widget.leadingWidget != null) return widget.leadingWidget!;

    if (widget.imageUrl != null) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AdvancedNetworkImage(
          imageUrl: widget.imageUrl!,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(19),
        ),
      );
    }

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: widget.accentColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.notifications_rounded,
          color: widget.accentColor,
          size: 18,
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
