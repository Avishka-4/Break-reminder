import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Session {
  final DateTime start;
  final DateTime end;
  final String type; // 'focus' or 'break'

  Session({required this.start, required this.end, required this.type});

  int get durationSeconds => end.difference(start).inSeconds;

  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'type': type,
      };

  static Session fromJson(Map<String, dynamic> json) => Session(
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
        type: json['type'] as String,
      );
}

class StorageService {
  static const _keySessions = 'sessions';

  Future<List<Session>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keySessions) ?? [];
    return raw
        .map((s) => json.decode(s) as Map<String, dynamic>)
        .map(Session.fromJson)
        .toList();
  }

  Future<void> addSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keySessions) ?? [];
    raw.add(json.encode(session.toJson()));
    await prefs.setStringList(_keySessions, raw);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySessions);
  }
}
