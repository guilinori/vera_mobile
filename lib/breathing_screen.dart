import 'package:flutter/material.dart';

class BreathingActivityRecord {
  final String technique;
  final String duration;
  final String timestamp;

  BreathingActivityRecord({required this.technique, required this.duration, required this.timestamp});
}

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  String _selectedTechnique = 'Cycle Sighing';
  int _selectedDurationSeconds = 300;
  bool _isSessionActive = false;
  
  final List<BreathingActivityRecord> _historyRecords = [
    BreathingActivityRecord(technique: 'Cycle Sighing', duration: '5 mins', timestamp: '10:30 AM'),
    BreathingActivityRecord(technique: 'Box Breathing', duration: '1 min', timestamp: '09:15 AM'),
  ];

  void _startSession() {
    setState(() {
      _isSessionActive = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isSessionActive) {
        setState(() {
          _isSessionActive = false;
          _historyRecords.insert(
            0,
            BreathingActivityRecord(
              technique: _selectedTechnique,
              duration: _formatDuration(_selectedDurationSeconds),
              timestamp: TimeOfDay.now().format(context),
            ),
          );
        });
      }
    });
  }

  void _stopSession() {
    setState(() {
      _isSessionActive = false;
    });
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds secs';
    return '${seconds ~/ 60} min${seconds > 60 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Breathing Exercises', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['Cycle Sighing', 'Physiological Sigh', 'Box Breathing'].map((technique) {
                  final isSelected = _selectedTechnique == technique;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(technique, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.white70)),
                      selected: isSelected,
                      selectedColor: Colors.blue,
                      backgroundColor: const Color(0xFF1E293B),
                      onSelected: (selected) {
                        setState(() {
                          _selectedTechnique = technique;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [10, 60, 180, 300].map((sec) {
                  final isSelected = _selectedDurationSeconds == sec;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(_formatDuration(sec), style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.white60)),
                      selected: isSelected,
                      selectedColor: Colors.blueAccent,
                      backgroundColor: const Color(0xFF1E293B),
                      onSelected: (selected) {
                        setState(() {
                          _selectedDurationSeconds = sec;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5), width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSessionActive ? 'Breathe...' : 'Ready?',
                        style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(_selectedDurationSeconds),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'A 5-Min Reset Backed by Research',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSessionActive ? Colors.redAccent : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _isSessionActive ? _stopSession : _startSession,
                child: Text(_isSessionActive ? 'Stop Session' : 'Start Session', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 32),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'BREATHING ACTIVITY RECORD',
                  style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
              ),
              const SizedBox(height: 12),

              if (_historyRecords.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No breathing sessions recorded yet. Start a session above!',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                )
              else
                ..._historyRecords.map((record) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Fixed
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(record.technique, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text('Duration: ${record.duration}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ],
                          ),
                          Text(record.timestamp, style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}