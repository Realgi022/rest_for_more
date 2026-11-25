import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusSession {
  final DateTime endedAt;
  final int seconds;
  final bool completed;

  const FocusSession({
    required this.endedAt,
    required this.seconds,
    required this.completed,
  });

  Map<String, Object?> toJson() => {
        'endedAt': endedAt.millisecondsSinceEpoch,
        'seconds': seconds,
        'completed': completed,
      };

  static FocusSession fromJson(Map<String, Object?> json) => FocusSession(
        endedAt: DateTime.fromMillisecondsSinceEpoch(json['endedAt'] as int),
        seconds: json['seconds'] as int,
        completed: json['completed'] as bool? ?? true,
      );
}

final focusHistoryService = FocusHistoryService._();

class FocusHistoryService extends ChangeNotifier {
  static const _key = 'focus_history';
  static const _maxEntries = 100;

  FocusHistoryService._() {
    _ready = _load();
  }

  late final Future<void> _ready;
  final List<FocusSession> _sessions = [];

  List<FocusSession> get sessions => List.unmodifiable(_sessions);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? const <String>[];
    for (final item in saved) {
      try {
        _sessions.add(
          FocusSession.fromJson(
            Map<String, Object?>.from(jsonDecode(item) as Map),
          ),
        );
      } catch (_) {}
    }
    _sessions.sort((a, b) => b.endedAt.compareTo(a.endedAt));
    notifyListeners();
  }

  Future<void> record({required int seconds, required bool completed}) async {
    if (seconds <= 0) return;
    await _ready;

    _sessions.insert(
      0,
      FocusSession(
        endedAt: DateTime.now(),
        seconds: seconds,
        completed: completed,
      ),
    );
    if (_sessions.length > _maxEntries) {
      _sessions.removeRange(_maxEntries, _sessions.length);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _sessions.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }
}
