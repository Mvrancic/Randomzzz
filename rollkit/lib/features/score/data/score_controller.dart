import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/colors.dart';
import '../domain/score_state.dart';

final scoreControllerProvider = StateNotifierProvider<ScoreController, ScoreState>((ref) {
  return ScoreController();
});

class ScoreController extends StateNotifier<ScoreState> {
  ScoreController() : super(const ScoreState(players: [])) {
    // Initialize with 2 teams for Versus Mode by default
    resetToDefaults();
  }

  void resetToDefaults() {
    state = const ScoreState(players: [
      ScorePlayer(id: '1', name: 'Team 1', color: AppColors.neonCyan),
      ScorePlayer(id: '2', name: 'Team 2', color: AppColors.neonPink),
    ]);
  }

  void addPlayer() {
    if (state.players.length >= 8) return;
    
    final id = const Uuid().v4();
    final index = state.players.length;
    final name = 'Team ${index + 1}';
    final color = _getColor(index);
    
    state = state.copyWith(
      players: [...state.players, ScorePlayer(id: id, name: name, color: color)],
    );
  }

  void removePlayer(String id) {
    if (state.players.length <= 2) return; // Keep at least 2
    state = state.copyWith(
      players: state.players.where((p) => p.id != id).toList(),
    );
  }

  void updateScore(String id, int delta) {
    state = state.copyWith(
      players: state.players.map((p) {
        if (p.id == id) {
          return p.copyWith(score: p.score + delta);
        }
        return p;
      }).toList(),
    );
  }
  
  void updateName(String id, String newName) {
     if (newName.trim().isEmpty) return;
     state = state.copyWith(
      players: state.players.map((p) {
        if (p.id == id) {
          return p.copyWith(name: newName.trim());
        }
        return p;
      }).toList(),
    );
  }

  void resetScores() {
    state = state.copyWith(
      players: state.players.map((p) => p.copyWith(score: 0)).toList(),
    );
  }
  
  // Load standard players (Game Night)
  void loadPlayers(List<dynamic> players) {
    if (players.isEmpty) return;
    
    // Convert to ScorePlayer
    final newPlayers = players.asMap().entries.map((entry) {
      final index = entry.key;
      final p = entry.value;
      // p is assumed to have .name and .id
      return ScorePlayer(
        id: p.id,
        name: p.name,
        color: _getColor(index),
        score: 0,
      );
    }).toList();
    
    state = state.copyWith(players: newPlayers);
  }
  
  // Load from Team Picker results
  void loadTeams(List<List<String>> teams) {
    if (teams.isEmpty) return;
    
    final newPlayers = teams.asMap().entries.map((entry) {
      final index = entry.key;
      // final members = entry.value; // List of names
      return ScorePlayer(
        id: const Uuid().v4(),
        name: 'Team ${index + 1}', // Keep consistent team naming
        color: _getColor(index),
        score: 0,
      );
    }).toList();
    
    state = state.copyWith(players: newPlayers);
  }

  Color _getColor(int index) {
    const colors = [
      AppColors.neonCyan,
      AppColors.neonPink,
      AppColors.neonGreen,
      AppColors.neonPurple,
      Color(0xFFFFD740), // Amber
      Color(0xFFFF6E40), // Deep Orange
      Color(0xFFEA80FC), // Purple Accent
      Color(0xFF69F0AE), // Mint
    ];
    return colors[index % colors.length];
  }
}
