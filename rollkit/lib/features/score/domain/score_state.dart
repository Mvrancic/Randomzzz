import 'package:flutter/material.dart';

class ScorePlayer {
  final String id;
  final String name;
  final int score;
  final Color? color;

  const ScorePlayer({
    required this.id,
    required this.name,
    this.score = 0,
    this.color,
  });

  ScorePlayer copyWith({
    String? name,
    int? score,
    Color? color,
  }) {
    return ScorePlayer(
      id: id,
      name: name ?? this.name,
      score: score ?? this.score,
      color: color ?? this.color,
    );
  }
}

class ScoreState {
  final List<ScorePlayer> players;

  const ScoreState({this.players = const []});
  
  // Computed
  bool get isVersusMode => players.length == 2;

  ScoreState copyWith({List<ScorePlayer>? players}) {
    return ScoreState(players: players ?? this.players);
  }
}
