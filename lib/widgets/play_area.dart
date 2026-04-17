import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../logic/recipe_manager.dart';
import '../models/emoji_item.dart';
import 'emoji_widget.dart';

// ── Data class for active particle effects ────────────────────

class _ParticleEffect {
  final Offset position;
  final String emoji;
  _ParticleEffect({required this.position, required this.emoji});
}

// ── Play Area ─────────────────────────────────────────────────

class PlayArea extends StatefulWidget {
  const PlayArea({Key? key}) : super(key: key);

  @override
  State<PlayArea> createState() => _PlayAreaState();
}

class _PlayAreaState extends State<PlayArea> {
  final List<_ParticleEffect> _particles = [];
  int _lastTrigger = 0;
  late GameController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller = context.read<GameController>();
      _controller.addListener(_onControllerChange);
    });
  }

  void _onControllerChange() {
    if (_controller.mergeParticleTrigger != _lastTrigger) {
      _lastTrigger = _controller.mergeParticleTrigger;
      if (_controller.lastMergePosition != null) {
        final pos = _controller.lastMergePosition!;
        final emoji = _controller.canvasEmojis.isNotEmpty
            ? _controller.canvasEmojis.last.emoji
            : '✨';
        final effect = _ParticleEffect(position: pos, emoji: emoji);
        if (mounted) {
          setState(() => _particles.add(effect));
          Future.delayed(const Duration(milliseconds: 750), () {
            if (mounted) setState(() => _particles.remove(effect));
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.offset);
        controller.addEmojiToCanvas(details.data, localPos);
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            // Background
            Positioned.fill(
              child: _GameBackground(hovered: candidateData.isNotEmpty),
            ),

            // Canvas emojis
            ...controller.canvasEmojis.map((item) {
              return Positioned(
                left: item.position.dx,
                top: item.position.dy,
                child: Draggable<EmojiItem>(
                  data: item,
                  feedback: Material(
                    color: Colors.transparent,
                    child: EmojiWidget(item: item),
                  ),
                  childWhenDragging: const SizedBox.shrink(),
                  onDragEnd: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final localPos = box.globalToLocal(details.offset);
                    final clamped = Offset(
                      localPos.dx.clamp(0.0, box.size.width - 60),
                      localPos.dy.clamp(0.0, box.size.height - 60),
                    );
                    controller.updateEmojiPosition(item.id, clamped);
                    controller
                        .checkCollision(item.copyWith(position: clamped));
                  },
                  child: EmojiWidget(item: item),
                ),
              );
            }),

            // Particle effects
            ..._particles.map((effect) {
              return Positioned(
                left: effect.position.dx - 100,
                top: effect.position.dy - 100,
                child: IgnorePointer(
                  child:
                      _MergeParticleWidget(emoji: effect.emoji),
                ),
              );
            }),

            // Empty state
            if (controller.canvasEmojis.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '⚗️',
                      style: TextStyle(
                        fontSize: 60,
                        color: Colors.white.withOpacity(0.10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Drag emojis from the tray below',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.18),
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Subtle grid background ────────────────────────────────────

class _GameBackground extends StatelessWidget {
  final bool hovered;
  const _GameBackground({this.hovered = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.4,
          colors: hovered
              ? [const Color(0xFF221538), const Color(0xFF0D0D14)]
              : [const Color(0xFF16102A), const Color(0xFF0D0D14)],
        ),
      ),
      child: CustomPaint(
        painter: _GridPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;
    const spacing = 44.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

// ── Particle widget ───────────────────────────────────────────

class _MergeParticleWidget extends StatefulWidget {
  final String emoji;
  const _MergeParticleWidget({required this.emoji});

  @override
  State<_MergeParticleWidget> createState() => _MergeParticleWidgetState();
}

class _MergeParticleWidgetState extends State<_MergeParticleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )
      ..addListener(() => setState(() {}))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _categoryColor() {
    final cat = RecipeManager.getEmojiCategory(widget.emoji);
    switch (cat) {
      case 'Elements':
        return Colors.deepOrangeAccent;
      case 'Nature':
        return Colors.lightGreenAccent;
      case 'Magic':
        return Colors.purpleAccent;
      case 'Life':
        return Colors.pinkAccent;
      case 'Tech':
        return Colors.lightBlueAccent;
      case 'Food':
        return Colors.yellowAccent;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _ParticlePainter(
          progress: _ctrl.value,
          color: _categoryColor(),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const count = 20;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi + (i.isEven ? 0.15 : -0.15);
      final speed = 45.0 + (i % 5) * 14.0;
      final radius = 3.5 + (i % 4) * 1.5;
      final distance = speed * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      fillPaint.color = color.withOpacity(opacity * 0.9);
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * distance,
          center.dy + math.sin(angle) * distance,
        ),
        radius * (1 - progress * 0.4),
        fillPaint,
      );
    }

    // Centre flash
    if (progress < 0.25) {
      final flashOpacity =
          ((0.25 - progress) / 0.25).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        65 * (progress / 0.25),
        Paint()
          ..color = color.withOpacity(flashOpacity * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
