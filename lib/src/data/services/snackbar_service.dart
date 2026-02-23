import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

enum SnackbarType { success, error, warning, info }

class SnackbarService {
  static OverlayEntry? _entry;

  void showSnackBar(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.success,
    Duration duration = const Duration(seconds: 4),
  }) {
    _entry?.remove();

    final overlay = Overlay.of(context);
    final controller = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 260),
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _entry = OverlayEntry(
      builder: (_) => _AnimatedSnackbar(
        message: message,
        type: type,
        animation: animation,
        onClose: () async {
          await controller.reverse();
          _entry?.remove();
          _entry = null;
        },
      ),
    );

    overlay.insert(_entry!);
    controller.forward();

    Timer(duration, () async {
      if (controller.isCompleted) {
        await controller.reverse();
        _entry?.remove();
        _entry = null;
      }
    });
  }
}

class _AnimatedSnackbar extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final Animation<double> animation;
  final VoidCallback onClose;

  const _AnimatedSnackbar({
    required this.message,
    required this.type,
    required this.animation,
    required this.onClose,
  });

  @override
  State<_AnimatedSnackbar> createState() => _AnimatedSnackbarState();
}

class _AnimatedSnackbarState extends State<_AnimatedSnackbar> {
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final theme = _SnackbarTheme.fromType(widget.type);

    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (_, __) {
          return Opacity(
            opacity: widget.animation.value,
            child: Transform.translate(
              offset: Offset(
                _dragOffset.dx,
                28 * (1 - widget.animation.value) + _dragOffset.dy,
              ),
              child: Transform.scale(
                scale: 0.96 + (0.04 * widget.animation.value),
                child: _gestureWrapper(theme),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _gestureWrapper(_SnackbarTheme theme) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond;
        final speed = velocity.distance;

        if (speed > 700) {
          _dismissInDirection(velocity);
        } else {
          // Snap back if swipe is weak
          setState(() => _dragOffset = Offset.zero);
        }
      },
      child: _content(theme),
    );
  }

  void _dismissInDirection(Offset velocity) {
    final Size screen = MediaQuery.of(context).size;

    Offset targetOffset;

    if (velocity.dy.abs() > velocity.dx.abs()) {
      // Vertical swipe
      targetOffset = Offset(0, screen.height * 0.5 * velocity.dy.sign);
    } else {
      // Horizontal swipe
      targetOffset = Offset(screen.width * velocity.dx.sign, 0);
    }

    setState(() {
      _dragOffset = targetOffset;
    });

    widget.onClose();
  }

  Widget _content(_SnackbarTheme theme) {
    return Material(
      type: MaterialType.transparency,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.background.withOpacity(0.94),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _accent(theme.accent),
                const SizedBox(width: 12),
                Expanded(child: _text()),
                InkResponse(
                  onTap: widget.onClose,
                  radius: 20,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _accent(Color color) => Container(
    width: 3,
    height: 30,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(3),
    ),
  );

  Widget _text() => Text(
    widget.message,
    maxLines: 3,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.35,
      letterSpacing: 0.2,
    ),
  );
}

class _SnackbarTheme {
  final Color background;
  final Color accent;

  _SnackbarTheme(this.background, this.accent);

  static _SnackbarTheme fromType(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarTheme(const Color(0xFF121212), const Color(0xFF2ECC71));
      case SnackbarType.error:
        return _SnackbarTheme(const Color(0xFF121212), const Color(0xFFE74C3C));
      case SnackbarType.warning:
        return _SnackbarTheme(const Color(0xFF121212), const Color(0xFFF39C12));
      case SnackbarType.info:
        return _SnackbarTheme(const Color(0xFF121212), const Color(0xFF3498DB));
    }
  }
}
