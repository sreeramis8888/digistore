import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:digistore/src/data/services/navigation_service.dart';

enum ToastType { success, error, warning, info }

class ToastService {
  static OverlayEntry? _entry;

  void showToast(
    BuildContext context,
    String message, {
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 3),
    bool autoDismiss = true,
  }) {
    final overlayState = Overlay.maybeOf(context) ?? NavigationService.navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint("❌ Overlay is null");
      return;
    }

    _entry?.remove();
    _entry = null;

    final controller = AnimationController(
      vsync: overlayState,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );

    _entry = OverlayEntry(
      builder: (_) => _AnimatedToast(
        message: message,
        type: type,
        animation: animation,
        onClose: () async {
          if (controller.isAnimating || controller.isCompleted) {
            await controller.reverse();
          }
          _entry?.remove();
          _entry = null;
          controller.dispose();
        },
      ),
    );

    overlayState.insert(_entry!);
    controller.forward();

    if (autoDismiss) {
      Timer(duration, () async {
        if (_entry != null && controller.isCompleted) {
          await controller.reverse();
          _entry?.remove();
          _entry = null;
          controller.dispose();
        }
      });
    }
  }
}

class _AnimatedToast extends StatefulWidget {
  final String message;
  final ToastType type;
  final Animation<double> animation;
  final VoidCallback onClose;

  const _AnimatedToast({
    required this.message,
    required this.type,
    required this.animation,
    required this.onClose,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast> {
  Offset _dragOffset = Offset.zero;
  Offset _dismissDirection = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final theme = _ToastTheme.fromType(widget.type);
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      left: 16,
      right: 16,
      top: topPadding + 12,
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (_, _) {
          final progress = widget.animation.value;

          final entryOffset = Offset(0, -40 * (1 - progress));
          final exitOffset = _dismissDirection * 120 * (1 - progress);

          return Opacity(
            opacity: progress.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: _dragOffset + entryOffset + exitOffset,
              child: Transform.scale(
                scale: 0.9 + (0.1 * progress),
                child: _gestureWrapper(theme),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _gestureWrapper(_ToastTheme theme) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond;

        final shouldDismiss =
            velocity.distance > 600 || _dragOffset.distance > 40;

        if (shouldDismiss) {
          _dismissDirection = velocity.distance > 0
              ? velocity / velocity.distance
              : _dragOffset / _dragOffset.distance;

          widget.onClose();
        } else {
          setState(() => _dragOffset = Offset.zero);
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Align(alignment: Alignment.topCenter, child: _content(theme)),
      ),
    );
  }

  Widget _content(_ToastTheme theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(theme.icon, size: 14, color: theme.accent),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: widget.onClose,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToastTheme {
  final Color accent;
  final IconData icon;

  _ToastTheme(this.accent, this.icon);

  static _ToastTheme fromType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastTheme(const Color(0xFF4CAF50), Icons.check);
      case ToastType.error:
        return _ToastTheme(const Color(0xFFE57373), Icons.priority_high);
      case ToastType.warning:
        return _ToastTheme(
          const Color(0xFFFFB74D),
          Icons.warning_amber_rounded,
        );
      case ToastType.info:
        return _ToastTheme(const Color(0xFF64B5F6), Icons.info_outline);
    }
  }
}
