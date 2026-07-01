import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/offers_provider.dart';
import '../../../data/services/toast_service.dart';
import '../../components/primary_button.dart';

class ScratchCardPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;

  const ScratchCardPage({super.key, required this.args});

  @override
  ConsumerState<ScratchCardPage> createState() => _ScratchCardPageState();
}

class _ScratchCardPageState extends ConsumerState<ScratchCardPage>
    with TickerProviderStateMixin {
  final List<Offset?> _scratchPoints = [];
  final Set<int> _scratchedCells = {};
  final List<_TouchParticle> _particles = [];

  bool isRevealing = false;
  bool isRevealed = false;
  num? awardedDiscount;

  late AnimationController _shimmerController;
  late AnimationController _particleController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    if (widget.args['isScratched'] == true) {
      isRevealed = true;
      awardedDiscount = widget.args['awardedDiscount'] as num?;
    }

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateParticles);
    _particleController.repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (isRevealed || awardedDiscount != null) {
      _scaleController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _particleController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _updateParticles() {
    if (_particles.isEmpty) return;
    setState(() {
      for (int i = _particles.length - 1; i >= 0; i--) {
        _particles[i].update();
        if (_particles[i].isDead) {
          _particles.removeAt(i);
        }
      }
    });
  }

  void _spawnParticles(Offset pos) {
    final math.Random rnd = math.Random();
    for (int i = 0; i < 3; i++) {
      final double angle = rnd.nextDouble() * 2 * math.pi;
      final double speed = rnd.nextDouble() * 2.8 + 0.8;
      _particles.add(
        _TouchParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: i % 2 == 0
              ? const Color(0xFFFFD700)
              : const Color(0xFF60A5FA),
        ),
      );
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (isRevealed) return;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPosition = details.localPosition;
    if (localPosition.dx < 0 ||
        localPosition.dy < 0 ||
        localPosition.dx > size.width ||
        localPosition.dy > size.height) {
      return;
    }

    if (_scratchPoints.length % 5 == 0) {
      HapticFeedback.selectionClick();
    }

    _spawnParticles(localPosition);

    setState(() {
      _scratchPoints.add(localPosition);
    });

    final int cols = 10;
    final int rows = 10;
    final double cellWidth = size.width / cols;
    final double cellHeight = size.height / rows;

    final int col = (localPosition.dx / cellWidth).floor().clamp(0, cols - 1);
    final int row = (localPosition.dy / cellHeight).floor().clamp(0, rows - 1);

    for (int r = row - 1; r <= row + 1; r++) {
      for (int c = col - 1; c <= col + 1; c++) {
        if (r >= 0 && r < rows && c >= 0 && c < cols) {
          _scratchedCells.add(r * cols + c);
        }
      }
    }

    final double progress = _scratchedCells.length / (cols * rows);

    // Fetch discount API silently at 15% without removing scratch layer
    if (progress >= 0.15 && !isRevealing && awardedDiscount == null) {
      _fetchDiscount();
    }

    // Only clear out the scratch layer once 75% of the card has been scratched away
    if (progress >= 0.75 && !isRevealed && awardedDiscount != null) {
      HapticFeedback.heavyImpact();
      setState(() {
        isRevealed = true;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (isRevealed) return;
    _scratchPoints.add(null);
    final double progress = _scratchedCells.length / 100.0;
    if (progress >= 0.15 && !isRevealing && awardedDiscount == null) {
      _fetchDiscount();
    }
    if (progress >= 0.75 && !isRevealed && awardedDiscount != null) {
      HapticFeedback.heavyImpact();
      setState(() {
        isRevealed = true;
      });
    }
  }

  Future<void> _fetchDiscount() async {
    if (isRevealing || awardedDiscount != null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      isRevealing = true;
    });

    final offerId = widget.args['id'] ?? widget.args['_id'] ?? '';
    if (offerId.toString().isEmpty) {
      ToastService().showToast(
        context,
        'Invalid offer ID',
        type: ToastType.error,
      );
      setState(() => isRevealing = false);
      return;
    }

    final response = await ref
        .read(offersProvider.notifier)
        .scratchOffer(offerId.toString());

    if (response.success) {
      final dataMap = response.data?['data'] is Map
          ? response.data!['data'] as Map
          : (response.data ?? {});
      final discount = dataMap['awardedDiscount'] as num?;

      final currentOffers = ref.read(offersProvider).offers;
      final existingOffer = currentOffers
          .where((o) => o.id == offerId)
          .firstOrNull ??
          ref
              .read(offersProvider)
              .exploreOffers
              .where((o) => o.id == offerId)
              .firstOrNull;

      if (existingOffer != null) {
        ref.read(offersProvider.notifier).updateOfferLocally(
              existingOffer.copyWith(
                isScratched: true,
                awardedDiscount: discount,
              ),
            );
      }

      widget.args['isScratched'] = true;
      widget.args['awardedDiscount'] = discount;

      if (mounted) {
        setState(() {
          isRevealing = false;
          awardedDiscount = discount;
        });
        _scaleController.forward(from: 0.0);
        // ToastService().showToast(
        //   context,
        //   response.data?['message'] ?? 'Scratch card revealed successfully!',
        //   type: ToastType.success,
        // );
      }
    } else {
      if (mounted) {
        setState(() {
          isRevealing = false;
        });
        ToastService().showToast(
          context,
          response.message ?? 'Failed to reveal scratch card.',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Smaller, more compact card size (240x240)
    const double cardSize = 240.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),

                // Animated Advanced Shimmer Border around Compact Card
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Container(
                      width: cardSize,
                      height: cardSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: isRevealed
                              ? [
                                  const Color(0xFF3B82F6),
                                  const Color(0xFF1D4ED8),
                                ]
                              : [
                                  const Color(0xFF1E40AF),
                                  const Color(0xFF3B82F6),
                                  const Color(0xFF60A5FA),
                                  const Color(0xFF1E40AF),
                                ],
                          stops: isRevealed ? null : const [0.0, 0.35, 0.65, 1.0],
                          transform: isRevealed
                              ? null
                              : GradientRotation(_shimmerController.value * 2 * math.pi),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2B6BFF).withOpacity(0.22),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2.5), // High-precision gradient frame
                      child: child,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(21.5),
                    child: Stack(
                      children: [
                        // Underneath Layer: Compact Revealed Reward Area
                        Container(
                          width: cardSize,
                          height: cardSize,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFF8FAFC),
                                Color(0xFFEFF6FF),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: isRevealing && awardedDiscount == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Color(0xFF2B6BFF),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Revealing reward...',
                                        style: TextStyle(
                                          color: Color(0xFF1E3A8A),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : ScaleTransition(
                                    scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                                      CurvedAnimation(
                                        parent: _scaleController,
                                        curve: Curves.easeOutBack,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFDBEAFE),
                                                Color(0xFFBFDBFE),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF3B82F6)
                                                    .withOpacity(0.2),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.celebration_rounded,
                                            color: Color(0xFF1D4ED8),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          awardedDiscount != null
                                              ? '${awardedDiscount}% OFF'
                                              : 'UNLOCKED!',
                                          style: const TextStyle(
                                            color: Color(0xFF1E3A8A),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3B82F6)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            '✨ Reward Verified',
                                            style: TextStyle(
                                              color: Color(0xFF2563EB),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),

                        // Top Scratch Layer: Advanced Blue Confetti Card
                        if (!isRevealed)
                          GestureDetector(
                            onPanUpdate: (details) =>
                                _onPanUpdate(details, const Size(cardSize, cardSize)),
                            onPanEnd: _onPanEnd,
                            child: CustomPaint(
                              size: const Size(cardSize, cardSize),
                              painter: _AdvancedBlueScratchPainter(
                                points: _scratchPoints,
                              ),
                              child: Stack(
                                children: _particles.map((p) {
                                  return Positioned(
                                    left: p.position.dx - 4,
                                    top: p.position.dy - 4,
                                    child: Opacity(
                                      opacity: p.life.clamp(0.0, 1.0),
                                      child: Icon(
                                        Icons.auto_awesome,
                                        size: 8 + (p.life * 5),
                                        color: p.color,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Caption Text matching clean minimalist layout
                Text(
                  (isRevealed || awardedDiscount != null)
                      ? 'Congratulations! You unlocked your reward'
                      : 'Scratch the Card to reveal\nyour reward',
                  style: const TextStyle(
                    color: Color(0xFF6A7181),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 44),

                // Continue Button when unlocked or revealed
                if (isRevealed || awardedDiscount != null) ...[
                  PrimaryButton(
                    text: 'Continue',
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                        'redemptionInstructions',
                        arguments: widget.args,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TouchParticle {
  Offset position;
  Offset velocity;
  Color color;
  double life = 1.0;

  _TouchParticle({
    required this.position,
    required this.velocity,
    required this.color,
  });

  void update() {
    position += velocity;
    life -= 0.05;
  }

  bool get isDead => life <= 0;
}

class _AdvancedBlueScratchPainter extends CustomPainter {
  final List<Offset?> points;

  _AdvancedBlueScratchPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.saveLayer(rect, Paint());

    // 1. Rich Radial/Linear Blue Background
    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2F6DFF), Color(0xFF1D55EE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Subtle security grid watermark across foil surface
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // 2. Confetti & Streamers
    _drawConfetti(canvas, size);

    // 3. Central Gift Box Illustration
    _drawGiftBox(canvas, Offset(size.width / 2, size.height / 2));

    // 4. Erase Scratched Points
    final Paint eraserPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = 44.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, eraserPaint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawCircle(points[i]!, 22.0, eraserPaint);
      }
    }

    canvas.restore();
  }

  void _drawConfetti(Canvas canvas, Size size) {
    final Paint goldPaint = Paint()..color = const Color(0xFFFFC107);
    final Paint goldShadow = Paint()..color = const Color(0xFFFF9800);

    void drawCoin(Offset center, double w, double h, double angle) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w, height: h), goldPaint);
      canvas.drawArc(
        Rect.fromCenter(center: Offset.zero, width: w * 0.7, height: h * 0.7),
        0,
        math.pi,
        false,
        goldShadow..style = PaintingStyle.stroke..strokeWidth = 1.5,
      );
      canvas.restore();
    }

    drawCoin(const Offset(88, 44), 16, 8, -0.3);
    drawCoin(const Offset(152, 50), 14, 7, 0.4);
    drawCoin(const Offset(160, 130), 16, 9, -0.2);
    drawCoin(const Offset(78, 134), 13, 7, 0.5);

    final Paint cyanPaint = Paint()
      ..color = const Color(0xFF40C4FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    void drawStreamer(Offset start, double height) {
      final Path path = Path();
      path.moveTo(start.dx, start.dy);
      path.relativeCubicTo(10, height * 0.3, -10, height * 0.6, 5, height);
      canvas.drawPath(path, cyanPaint);
    }

    drawStreamer(const Offset(112, 38), 26);
    drawStreamer(const Offset(70, 108), 24);
    drawStreamer(const Offset(164, 104), 22);

    final Paint yellowBit = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(const Rect.fromLTWH(126, 44, 9, 9), 0, 2, false, yellowBit);
    canvas.drawArc(const Rect.fromLTWH(82, 102, 9, 9), 1, 2, false, yellowBit);
    canvas.drawArc(const Rect.fromLTWH(144, 132, 9, 9), 2, 2, false, yellowBit);

    final Paint starPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    void drawStar(Offset center, double r) {
      canvas.drawLine(Offset(center.dx - r, center.dy), Offset(center.dx + r, center.dy), starPaint);
      canvas.drawLine(Offset(center.dx, center.dy - r), Offset(center.dx, center.dy + r), starPaint);
    }

    drawStar(const Offset(158, 40), 4.5);
    drawStar(const Offset(66, 50), 3.5);
    drawStar(const Offset(146, 96), 3);
  }

  void _drawGiftBox(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.18);

    final Paint boxPaint = Paint()..color = Colors.white;
    final Paint ribbonPaint = Paint()..color = const Color(0xFF4080FF);

    final Rect bodyRect = Rect.fromCenter(center: const Offset(0, 12), width: 48, height: 42);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(5)), boxPaint);

    final Rect lidRect = Rect.fromCenter(center: const Offset(0, -12), width: 55, height: 14);
    canvas.drawRRect(RRect.fromRectAndRadius(lidRect, const Radius.circular(4.5)), boxPaint);

    canvas.drawRect(Rect.fromLTWH(-5, -19, 10, 52), ribbonPaint);

    final Paint bowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawOval(const Rect.fromLTWH(-17, -27, 15, 10), bowPaint);
    canvas.drawOval(const Rect.fromLTWH(2, -27, 15, 10), bowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AdvancedBlueScratchPainter oldDelegate) => true;
}
