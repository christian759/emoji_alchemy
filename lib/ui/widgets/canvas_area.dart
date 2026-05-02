import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../data/element_data.dart';
import '../../models/emoji_element.dart';
import '../../models/placed_element.dart';
import '../../providers/game_state.dart';
import 'discovery_overlay.dart';
import 'emoji_bubble.dart';

class _CombinePreview {
  final String dragId;
  final String targetId;
  final EmojiElement result;
  final double distance;

  const _CombinePreview({
    required this.dragId,
    required this.targetId,
    required this.result,
    required this.distance,
  });
}

class CanvasArea extends StatefulWidget {
  const CanvasArea({super.key});

  @override
  State<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<CanvasArea> with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  final double _canvasSize = 5000;
  final double _bubbleSize = 82;
  final double _previewThreshold = 128;
  final double _combineThreshold = 96;

  _CombinePreview? _preview;
  String? _draggingId;

  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.identity();
    _transformationController.value.setTranslationRaw(
      -(_canvasSize / 2) + 220,
      -(_canvasSize / 2) + 320,
      0,
    );
  }

  void _setPreview(_CombinePreview? preview) {
    if (!mounted) return;
    final didChange = _preview?.dragId != preview?.dragId ||
        _preview?.targetId != preview?.targetId ||
        _preview?.result.id != preview?.result.id;
    if (didChange) {
      setState(() {
        _preview = preview;
      });
    }
  }

  _CombinePreview? _findPreview(
    GameState gameState,
    String dragId,
    double x,
    double y,
  ) {
    _CombinePreview? closest;

    for (final element in gameState.canvasElements) {
      if (element.id == dragId) continue;

      final combo = gameState.combinationForElements(
        gameState.canvasElements.firstWhere((placed) => placed.id == dragId).element.id,
        element.element.id,
      );
      if (combo == null) continue;

      final dx = (element.x + _bubbleSize / 2) - (x + _bubbleSize / 2);
      final dy = (element.y + _bubbleSize / 2) - (y + _bubbleSize / 2);
      final distance = sqrt((dx * dx) + (dy * dy));
      if (distance > _previewThreshold) continue;

      final result = ElementData.elements[combo.result]!;
      if (closest == null || distance < closest.distance) {
        closest = _CombinePreview(
          dragId: dragId,
          targetId: element.id,
          result: result,
          distance: distance,
        );
      }
    }

    return closest;
  }

  Future<void> _showDiscovery(CombinationOutcome outcome) async {
    if (!mounted || !outcome.wasNewDiscovery) return;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => DiscoveryOverlay(outcome: outcome),
    );
  }

  void _attemptLiveCombination(
    GameState gameState,
    String dragId,
    double x,
    double y,
  ) {
    final preview = _findPreview(gameState, dragId, x, y);
    _setPreview(preview);

    if (preview == null || preview.distance > _combineThreshold) return;

    final outcome = gameState.attemptCombination(
      preview.dragId,
      preview.targetId,
      x,
      y,
    );

    _draggingId = null;
    _setPreview(null);

    if (outcome != null) {
      Future.microtask(() => _showDiscovery(outcome));
    }
  }

  void _handlePanUpdate(PlacedElement placed, DragUpdateDetails dragDetails) {
    final gameState = Provider.of<GameState>(context, listen: false);
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final nextX = placed.x + (dragDetails.delta.dx / scale);
    final nextY = placed.y + (dragDetails.delta.dy / scale);
    gameState.updateElementPosition(placed.id, nextX, nextY);
    _attemptLiveCombination(gameState, placed.id, nextX, nextY);
  }

  Widget _buildPreviewBanner(ThemeData theme) {
    if (_preview == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F0E1).withOpacity(0.96),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4B48A), width: 1.1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_motion_rounded, size: 18, color: Color(0xFF8A4F2B)),
            const SizedBox(width: 8),
            Text(
              'Slide elements together. A loose overlap is enough to mix.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B523D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2E241A).withOpacity(0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1B26C), width: 1.3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFF1C27D), size: 18),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Combination ready',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFF6ECDD),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Release nearby to make ${_preview!.result.name}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFF1C27D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 180.ms).slideY(begin: -0.25, duration: 180.ms);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        final gameState = Provider.of<GameState>(context, listen: false);
        final box = context.findRenderObject() as RenderBox;
        final localOffset = box.globalToLocal(details.offset);
        final sceneOffset = _transformationController.toScene(localOffset);

        final elementId = details.data;
        if (ElementData.elements.containsKey(elementId)) {
          gameState.addToCanvas(
            ElementData.elements[elementId]!,
            sceneOffset.dx,
            sceneOffset.dy,
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        return ClipRect(
          child: Stack(
            children: [
              InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: EdgeInsets.all(_canvasSize),
                minScale: 0.24,
                maxScale: 3.0,
                constrained: false,
                child: SizedBox(
                  width: _canvasSize,
                  height: _canvasSize,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFCF5EA),
                                Color(0xFFF4E3CB),
                                Color(0xFFEEDBC0),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.12,
                                  child: GridPaper(
                                    color: const Color(0xFFB98E60),
                                    interval: 108,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 120,
                                right: 160,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Color(0x26D79C55),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 220,
                                left: 140,
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Color(0x1FAE6C3F),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Consumer<GameState>(
                        builder: (context, gameState, child) {
                          return Stack(
                            children: gameState.canvasElements.map((placed) {
                              final isDragging = _draggingId == placed.id;
                              final isPreviewed = _preview?.dragId == placed.id || _preview?.targetId == placed.id;
                              final bubble = EmojiBubble(
                                element: placed.element,
                                size: _bubbleSize,
                                highlighted: isPreviewed,
                                compactLabel: true,
                                accentColor: const Color(0xFFE1B26C),
                              );

                              return Positioned(
                                left: placed.x,
                                top: placed.y,
                                child: GestureDetector(
                                  onPanStart: (_) {
                                    setState(() {
                                      _draggingId = placed.id;
                                    });
                                  },
                                  onPanUpdate: (dragDetails) => _handlePanUpdate(placed, dragDetails),
                                  onPanEnd: (_) {
                                    setState(() {
                                      _draggingId = null;
                                    });
                                    _setPreview(null);
                                  },
                                  onPanCancel: () {
                                    setState(() {
                                      _draggingId = null;
                                    });
                                    _setPreview(null);
                                  },
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 140),
                                    scale: isDragging ? 1.08 : (isPreviewed ? 1.03 : 1),
                                    child: bubble
                                        .animate(
                                          onPlay: (controller) => controller.repeat(reverse: true),
                                        )
                                        .moveY(
                                          begin: -2,
                                          end: 3,
                                          delay: Duration(milliseconds: (placed.element.name.length % 5) * 140),
                                          duration: (1800 + (placed.element.name.length * 40)).ms,
                                          curve: Curves.easeInOut,
                                        ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Center(child: _buildPreviewBanner(theme)),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD7B78E), width: 1),
                  ),
                  child: Text(
                    'Pinch to zoom • Drag to overlap • Instant mix when a recipe matches',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6A5039),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
