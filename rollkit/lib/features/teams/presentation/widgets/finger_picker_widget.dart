import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FingerPickerWidget extends StatefulWidget {
  final int teamCount;
  final Function(List<List<int>>) onTeamsGenerated; // Returns lists of pointer IDs

  const FingerPickerWidget({
    super.key,
    required this.teamCount,
    required this.onTeamsGenerated,
  });

  @override
  State<FingerPickerWidget> createState() => _FingerPickerWidgetState();
}

class _FingerPickerWidgetState extends State<FingerPickerWidget> with TickerProviderStateMixin {
  final Map<int, Offset> _pointers = {};
  final Map<int, Color> _assignments = {};
  Timer? _countdownTimer;
  int? _countdownValue;
  bool _isSelecting = false;

  void _onPointerDown(PointerEvent event) {
    if (_isSelecting) return;
    setState(() {
      _pointers[event.pointer] = event.position;
      _resetSelection();
    });
  }

  void _onPointerMove(PointerEvent event) {
    if (_isSelecting) return;
    if (_pointers.containsKey(event.pointer)) {
      setState(() {
        _pointers[event.pointer] = event.position;
      });
    }
  }

  void _onPointerUp(PointerEvent event) {
    setState(() {
      _pointers.remove(event.pointer);
      _assignments.remove(event.pointer);
      _resetSelection();
    });
  }

  void _resetSelection() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _countdownValue = null;
    _assignments.clear(); // Clear previous results immediately if fingers move/change
    
    if (_pointers.length >= 2) { // Minimum 2 players
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownValue = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdownValue! > 1) {
          _countdownValue = _countdownValue! - 1;
        } else {
          _countdownValue = null;
          timer.cancel();
          _assignTeams();
        }
      });
    });
  }

  void _assignTeams() {
    setState(() {
      _isSelecting = true;
    });

    // Shuffle pointer IDs
    final pointerIds = _pointers.keys.toList()..shuffle();
    final teams = List.generate(widget.teamCount, (_) => <int>[]);

    // Distribute
    for (int i = 0; i < pointerIds.length; i++) {
        teams[i % widget.teamCount].add(pointerIds[i]);
    }

    // Assign Colors based on Team Index
    for (int i = 0; i < teams.length; i++) {
      final color = _getTeamColor(i);
      for (final pid in teams[i]) {
        _assignments[pid] = color;
      }
    }
    
    // Slight delay before "finishing" visually if we wanted to show a success state
    // For now, we just stay in this state until fingers lift.
  }
  
   Color _getTeamColor(int index) {
    const colors = [
      AppColors.neonCyan,
      AppColors.neonGreen,
      AppColors.neonPink,
      AppColors.neonPurple,
      Color(0xFFFFD740),
      Color(0xFFFF6E40),
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      behavior: HitTestBehavior.opaque, // Catch all touches
      child: Stack(
        children: [
          // Background/Instruction
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_pointers.isEmpty)
                  const Text(
                    'Place fingers on screen\nto assign teams',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else if (_countdownValue != null)
                   Text(
                    '$_countdownValue',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                   ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack)
                else if (_assignments.isNotEmpty)
                   const Text(
                    'Teams Assigned!',
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                   ).animate().fadeIn(),
              ],
            ),
          ),

          // Render Rings
          ..._pointers.entries.map((entry) {
            final pid = entry.key;
            final pos = entry.value;
            final color = _assignments[pid] ?? AppColors.text.withValues(alpha: 0.5);
            final isAssigned = _assignments.containsKey(pid);

            return Positioned(
              left: pos.dx - 40,
              top: pos.dy - 120, // Offset slightly to see under finger? Or center it? Usually centered under finger.
              // Actually, Flutter coordinate is top-left.
              // Let's Center it.
              child: Transform.translate(
                offset: const Offset(0, -40), // Shift up so it's visible above the finger?
                // Standard chwazi is UNDER the finger, but big enough to see edge.
                child: _TouchRing(
                  color: color, 
                  isAssigned: isAssigned,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TouchRing extends StatelessWidget {
  final Color color;
  final bool isAssigned;

  const _TouchRing({required this.color, required this.isAssigned});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: isAssigned ? 6 : 2,
        ),
        color: color.withValues(alpha: isAssigned ? 0.3 : 0.1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: isAssigned ? 20 : 10,
            spreadRadius: isAssigned ? 5 : 0,
          ),
        ],
      ),
    ).animate(target: isAssigned ? 1 : 0)
    .scale(end: const Offset(1.2, 1.2), duration: 300.ms, curve: Curves.elasticOut);
  }
}
