import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mood_app/c_painter/mood_face_painter.dart';
import 'package:mood_app/models/mood_entry.dart';

class TimelineEntryCard extends StatefulWidget {
  final MoodEntry entry;
  final bool isLatest;

  const TimelineEntryCard({
    super.key,
    required this.entry,
    this.isLatest = false,
  });

  @override
  State<TimelineEntryCard> createState() => _TimelineEntryCardState();
}

class _TimelineEntryCardState extends State<TimelineEntryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _faceAnim;
  late Animation<double> _cardScaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _faceAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)),
    );
    _cardScaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    // Entrance animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Color moodColor = MoodData.colors[widget.entry.mood]!;
    final Color lightColor = MoodData.lightColors[widget.entry.mood]!;
    final String label = MoodData.labels[widget.entry.mood]!;
    final DateTime ts = widget.entry.timestamp;

    final String dayStr = DateFormat('EEE').format(ts);
    final String dateStr = DateFormat('MMM d').format(ts);
    final String timeStr = DateFormat('h:mm a').format(ts);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isLatest ? 1.0 : _cardScaleAnim.value,
            child: Container(
              width: 110,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: moodColor.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: moodColor.withOpacity(0.15 + 0.25 * _glowAnim.value),
                    blurRadius: 10 + 14 * _glowAnim.value,
                    spreadRadius: 1 + 4 * _glowAnim.value,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color accent header
                  Container(
                    decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Text(dayStr,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: moodColor,
                              letterSpacing: 0.8,
                            )),
                        Text(dateStr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: moodColor,
                            )),
                      ],
                    ),
                  ),
                  // Face
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomPaint(
                      size: const Size(64, 64),
                      painter: MoodFacePainter(
                        mood: widget.entry.mood,
                        animationValue: _faceAnim.value,
                        isSmall: true,
                      ),
                    ),
                  ),
                  // Label and time
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        Text(label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: moodColor,
                            )),
                        const SizedBox(height: 2),
                        Text(timeStr,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}