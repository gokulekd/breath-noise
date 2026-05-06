import 'package:flutter/material.dart';

import '../../../core/constants/scene_data.dart';
import '../../../core/theme/app_theme.dart';

class SceneCard extends StatefulWidget {
  final SceneDefinition scene;
  final bool isActive;
  final VoidCallback onTap;

  const SceneCard({
    super.key,
    required this.scene,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<SceneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnim.value, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: widget.scene.gradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isActive
                    ? widget.scene.accentColor.withAlpha(200)
                    : Colors.white.withAlpha(20),
                width: widget.isActive ? 2 : 1,
              ),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: widget.scene.primaryColor.withAlpha(100),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Optional Background Image
                  if (widget.scene.imageAsset != null)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.4,
                        child: Image.asset(
                          widget.scene.imageAsset!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    // Decorative background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CardGlowPainter(
                          color: widget.scene.accentColor,
                          isActive: widget.isActive,
                        ),
                      ),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Emoji & Premium badge row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(),
                            if (widget.scene.isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.amberGold.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppTheme.amberGold.withAlpha(120),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: AppTheme.amberGold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'FREE',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const Spacer(),

                        // Scene name
                        Text(
                          widget.scene.name,
                          style: TextStyle(
                            color: AppTheme.warmCream,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(120),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Tagline
                        Text(
                          widget.scene.tagline,
                          style: TextStyle(
                            color: Colors.white.withAlpha(160),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Play indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 3,
                          decoration: BoxDecoration(
                            color: widget.isActive
                                ? widget.scene.accentColor
                                : Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active glow overlay
                  if (widget.isActive)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              widget.scene.accentColor.withAlpha(15),
                              Colors.transparent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardGlowPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _CardGlowPainter({required this.color, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;
    final paint = Paint()
      ..color = color.withAlpha(20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.4,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CardGlowPainter oldDelegate) =>
      oldDelegate.isActive != isActive;
}
