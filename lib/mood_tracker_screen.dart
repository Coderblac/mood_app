import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage_service.dart';
import '../widgets/animated_mood_face.dart';
import '../widgets/timeline_entry_card.dart';
import 'dart:math';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with TickerProviderStateMixin {
  final MoodStorageService _storage = MoodStorageService();
  List<MoodEntry> _entries = [];
  MoodType _selectedMood = MoodType.happy;
  bool _isLogging = false;
  bool _justLogged = false;

  late AnimationController _headerController;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = CurvedAnimation(
        parent: _headerController, curve: Curves.easeOut);
    _headerController.forward();
    _loadEntries();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final entries = await _storage.loadEntries();
    if (mounted) {
      setState(() => _entries = entries);
    }
  }

  Future<void> _logMood() async {
    if (_isLogging) return;
    setState(() => _isLogging = true);

    final entry = MoodEntry(
      mood: _selectedMood,
      timestamp: DateTime.now(),
      id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
    );

    await _storage.saveEntry(entry);
    await _loadEntries();

    if (mounted) {
      setState(() {
        _isLogging = false;
        _justLogged = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _justLogged = false);
      });
    }
  }

  List<MoodEntry> get _recentEntries =>
      _entries.take(7).toList();

  Color get _selectedColor => MoodData.colors[_selectedMood]!;
  Color get _selectedLight => MoodData.lightColors[_selectedMood]!;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? size.width * 0.12 : 20,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 28),
                _buildMoodSelector(),
                const SizedBox(height: 24),
                _buildLogButton(),
                const SizedBox(height: 36),
                if (_recentEntries.isNotEmpty) ...[
                  _buildTimelineHeader(),
                  const SizedBox(height: 14),
                  _buildTimeline(),
                  const SizedBox(height: 32),
                ],
                if (_entries.isEmpty) _buildEmptyState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Mood Tracker',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _selectedColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_entries.isNotEmpty)
                Text(
                  '${_entries.length} entr${_entries.length == 1 ? 'y' : 'ies'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'How are you\nfeeling today?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _justLogged
                  ? 'Logged! Keep checking in.'
                  : MoodData.description(_selectedMood),
              key: ValueKey(_justLogged
                  ? 'logged'
                  : _selectedMood.toString()),
              style: TextStyle(
                fontSize: 15,
                color: _justLogged ? _selectedColor : Colors.grey[500],
                fontWeight:
                    _justLogged ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          // preview face
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _selectedLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedMoodFace(
              mood: _selectedMood,
              size: 130,
              autoAnimate: true,
            ),
          ),
          const SizedBox(height: 22),
          // Row of moods options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: MoodType.values.map((mood) {
              return TappableMoodFace(
                mood: mood,
                size: 52,
                isSelected: _selectedMood == mood,
                onTap: () => setState(() => _selectedMood = mood),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _selectedColor,
            _selectedColor.withOpacity(0.75),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _isLogging ? null : _logMood,
          child: Center(
            child: _isLogging
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_circle_outline,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Log this mood',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineHeader() {
    return Row(
      children: [
        Text(
          'Recent check-ins',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _selectedLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'tap to animate',
            style: TextStyle(
              fontSize: 10,
              color: _selectedColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _recentEntries.length,
        itemBuilder: (context, index) {
          return TimelineEntryCard(
            key: ValueKey(_recentEntries[index].id),
            entry: _recentEntries[index],
            isLatest: index == 0,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.mood_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No entries yet.\nLog your first mood above!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}