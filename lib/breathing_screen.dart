import 'dart:async';
import 'package:flutter/material.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  String selectedTechnique = 'Cycle Sighing';
  String selectedDuration = '10 secs';
  bool isSessionActive = false;
  
  Timer? _timer;
  int _totalSeconds = 10;
  int _remainingSeconds = 10;
  String _currentInstruction = 'Ready?';

  final List<String> techniques = ['Cycle Sighing', 'Physiological Sigh', 'Box Breathing'];
  final List<String> durations = ['10 secs', '1 min', '3 mins', '5 mins'];
  
  final List<String> activityHistory = [];

  int _getSecondsFromDuration(String duration) {
    switch (duration) {
      case '10 secs':
        return 10;
      case '1 min':
        return 60;
      case '3 mins':
        return 180;
      case '5 mins':
      default:
        return 300;
    }
  }

  void _startTimer() {
    int durationSecs = _getSecondsFromDuration(selectedDuration);
    setState(() {
      isSessionActive = true;
      _totalSeconds = durationSecs;
      _remainingSeconds = durationSecs;
      _currentInstruction = 'Inhale...';
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 1) {
          _remainingSeconds--;
          
          // Calculate dynamic breathing phases based on elapsed time (every 4-second cycle)
          int elapsed = _totalSeconds - _remainingSeconds;
          int cycleTime = elapsed % 12; // 12-second block for Box / Cyclic patterns
          
          if (selectedTechnique == 'Box Breathing') {
            if (cycleTime < 3) {
              _currentInstruction = 'Inhale...';
            } else if (cycleTime < 6) {
              _currentInstruction = 'Hold...';
            } else if (cycleTime < 9) {
              _currentInstruction = 'Exhale...';
            } else {
              _currentInstruction = 'Hold...';
            }
          } else {
            // Physiological / Cycle Sighing pattern
            if (cycleTime < 4) {
              _currentInstruction = 'Deep Inhale...';
            } else if (cycleTime < 6) {
              _currentInstruction = 'Quick Top-off Inhale...';
            } else {
              _currentInstruction = 'Slow Exhale...';
            }
          }
        } else {
          _stopTimer();
          _currentInstruction = 'Completed!';
          activityHistory.insert(
            0,
            '$selectedTechnique ($selectedDuration) completed at ${TimeOfDay.now().format(context)}',
          );
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      isSessionActive = false;
      _currentInstruction = 'Ready?';
    });
  }

  void _toggleSession() {
    if (isSessionActive) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  String _formatTime(int seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('Breathing Exercises', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Center-Aligned Technique Dropdown Container
            Center(
              child: Container(
                width: 240,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedTechnique,
                    isExpanded: true,
                    dropdownColor: Colors.grey.shade900,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent),
                    items: techniques.map((String technique) {
                      return DropdownMenuItem<String>(
                        value: technique,
                        child: Text(technique, textAlign: TextAlign.center),
                      );
                    }).toList(),
                    onChanged: isSessionActive ? null : (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedTechnique = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Center-Aligned Duration Dropdown Container
            Center(
              child: Container(
                width: 240,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedDuration,
                    isExpanded: true,
                    dropdownColor: Colors.grey.shade900,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent),
                    items: durations.map((String duration) {
                      return DropdownMenuItem<String>(
                        value: duration,
                        child: Text(duration, textAlign: TextAlign.center),
                      );
                    }).toList(),
                    onChanged: isSessionActive ? null : (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedDuration = newValue;
                          _remainingSeconds = _getSecondsFromDuration(newValue);
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live Countdown Timer Circle Container with Dynamic Instructions
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentInstruction,
                      style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSessionActive ? _formatTime(_remainingSeconds) : selectedDuration,
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Start / Stop Session Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSessionActive ? Colors.redAccent : Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _toggleSession,
                child: Text(
                  isSessionActive ? 'Stop Session' : 'Start Session',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Breathing Activity Record Section
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'BREATHING ACTIVITY RECORD',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: activityHistory.isEmpty
                  ? const Text(
                      'No breathing sessions recorded yet. Start a session above!',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: activityHistory.map((record) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('• $record', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      )).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}