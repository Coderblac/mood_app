import 'package:flutter/material.dart';

enum MoodType {  happy, neutral, sad, }

class MoodEntry {
  final MoodType mood;
  final DateTime timestamp;
  final String id;

  MoodEntry({
    required this.mood,
    required this.timestamp,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
        'mood': mood.index,
        'timestamp': timestamp.toIso8601String(),
        'id': id,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        mood: MoodType.values[json['mood'] as int],
        timestamp: DateTime.parse(json['timestamp'] as String),
        id: json['id'] as String,
      );
}

class MoodData {
  static const Map<MoodType, String> labels = {

    MoodType.happy: 'Happy',
    MoodType.neutral: 'Neutral',
    MoodType.sad: 'Sad',

  };

  static const Map<MoodType, Color> colors = {
    MoodType.happy: Color(0xFF66BB6A),
    MoodType.neutral: Color(0xFF42A5F5),
    MoodType.sad: Color(0xFFAB47BC),

  };

  static const Map<MoodType, Color> lightColors = {
    MoodType.happy: Color(0xFFE8F5E9),
    MoodType.neutral: Color(0xFFE3F2FD),
    MoodType.sad: Color(0xFFF3E5F5),

  };

  static String description(MoodType mood) {
    switch (mood) {

      case MoodType.happy:
        return 'Things are going well.';
      case MoodType.neutral:
        return 'Just getting through the day.';
      case MoodType.sad:
        return 'Feeling a bit down.';

    }
  }
}