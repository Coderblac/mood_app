import 'package:flutter/material.dart';
import 'package:mood_app/c_painter/face_painter.dart';
import 'package:mood_app/models/mood_entry.dart';



class AnimatedMoodFace extends StatefulWidget {
  final MoodType mood;
  final double size;
  final bool isSmall;
  final bool autoAnimate;

  const AnimatedMoodFace({
    super.key,
    required this.mood,
    this.size = 120,
    this.isSmall = false,
    this.autoAnimate = false,
  });

  @override
  State<AnimatedMoodFace> createState() => _AnimatedMoodFaceState();
}

class _AnimatedMoodFaceState extends State<AnimatedMoodFace>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    if (widget.autoAnimate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedMoodFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      _controller.forward(from: 0.0);
    }
  }

  void triggerAnimation() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: MoodFacePainter(
          mood: widget.mood,
          animationValue: _animation.value,
          isSmall: widget.isSmall,
        ),
      ),
    );
  }
}

/// A tappable mood face that bounces when pressed — used in the selector grid
class TappableMoodFace extends StatefulWidget {
  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;

  const TappableMoodFace({
    super.key,
    required this.mood,
    required this.isSelected,
    required this.onTap,
    this.size = 90,
  });

  @override
  State<TappableMoodFace> createState() => _TappableMoodFaceState();
}

class _TappableMoodFaceState extends State<TappableMoodFace>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final Color moodColor = MoodData.colors[widget.mood]!;
    final Color lightColor = MoodData.lightColors[widget.mood]!;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.isSelected ? lightColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? moodColor : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: moodColor.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: MoodFacePainter(mood: widget.mood),
              ),
              const SizedBox(height: 6),
              Text(
                MoodData.labels[widget.mood]!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isSelected ? moodColor : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}