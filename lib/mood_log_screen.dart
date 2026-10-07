import 'package:flutter/material.dart';

class MoodEntryModel {
  String emotionEmoji;
  String reflection;
  String dateGroup;
  String timestamp;

  MoodEntryModel({
    required this.emotionEmoji,
    required this.reflection,
    required this.dateGroup,
    required this.timestamp,
  });
}

class MoodLogScreen extends StatefulWidget {
  const MoodLogScreen({super.key});

  @override
  State<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends State<MoodLogScreen> {
  final TextEditingController _reflectionController = TextEditingController();
  String _selectedEmoji = '😊';
  bool _showAnalytics = false;

  final List<MoodEntryModel> _entries = [
    MoodEntryModel(
      emotionEmoji: '😔',
      reflection: 'I am tired, coding I want to eat tamal',
      dateGroup: 'October 2026',
      timestamp: '10:48 PM',
    ),
    MoodEntryModel(
      emotionEmoji: '😊',
      reflection: 'Feeling productive today working on Flutter!',
      dateGroup: 'October 2026',
      timestamp: '02:15 PM',
    ),
  ];

  final List<String> _emojis = ['😊', '😔', '🥳', '😡', '😰', '😴', '🤩'];

  void _recordEntry() {
    final text = _reflectionController.text.trim();
    setState(() {
      _entries.insert(
        0,
        MoodEntryModel(
          emotionEmoji: _selectedEmoji,
          reflection: text.isEmpty ? 'No reflection provided.' : text,
          dateGroup: 'October 2026',
          timestamp: TimeOfDay.now().format(context),
        ),
      );
      _reflectionController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mood entry recorded successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
  }

  void _navigateToEditScreen(int index) async {
    final entry = _entries[index];
    final updatedEntry = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMoodScreen(
          initialEmoji: entry.emotionEmoji,
          initialReflection: entry.reflection,
          emojis: _emojis,
        ),
      ),
    );

    if (updatedEntry != null && updatedEntry is Map<String, String>) {
      setState(() {
        entry.emotionEmoji = updatedEntry['emoji']!;
        entry.reflection = updatedEntry['reflection']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> emotionCounts = {};
    for (var entry in _entries) {
      emotionCounts[entry.emotionEmoji] = (emotionCounts[entry.emotionEmoji] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mood Log', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(_showAnalytics ? Icons.list : Icons.analytics_outlined, color: Colors.black87),
            onPressed: () => setState(() => _showAnalytics = !_showAnalytics),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_entries.length}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    const Text('Total Logs', style: TextStyle(color: Colors.black54, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_showAnalytics) ...[
                const Text(
                  'MOOD ANALYTICS & FREQUENCY',
                  style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: emotionCounts.entries.isEmpty
                        ? [const Text('No analytics data available yet.', style: TextStyle(color: Colors.black38))]
                        : emotionCounts.entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e.key, style: const TextStyle(fontSize: 24)),
                                  Text('${e.value} time(s) logged', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            )).toList(),
                  ),
                ),
              ] else ...[
                const Text(
                  'LOG HOW YOU FEEL',
                  style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _emojis.map((emoji) {
                    final isSelected = _selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = emoji),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withValues(alpha: 0.2) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? Colors.blue : const Color(0xFFE2E8F0)),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reflectionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write a short reflection or note about how you feel...',
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _recordEntry,
                    child: const Text('Record Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'REAL-TIME ACTIVITY HISTORY',
                  style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 12),

                if (_entries.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Text('No mood entries logged yet. Try recording one above!', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  )
                else
                  ..._entries.asMap().entries.map((entryItem) {
                    final index = entryItem.key;
                    final entry = entryItem.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.emotionEmoji, style: const TextStyle(fontSize: 28)),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.black54),
                                    onPressed: () => _navigateToEditScreen(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                    onPressed: () => _deleteEntry(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.reflection,
                            style: const TextStyle(color: Colors.black87, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.dateGroup, style: const TextStyle(color: Colors.black38, fontSize: 11)),
                              Text(entry.timestamp, style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Dedicated full-screen Edit Page (Notes style)
class EditMoodScreen extends StatefulWidget {
  final String initialEmoji;
  final String initialReflection;
  final List<String> emojis;

  const EditMoodScreen({
    super.key,
    required this.initialEmoji,
    required this.initialReflection,
    required this.emojis,
  });

  @override
  State<EditMoodScreen> createState() => _EditMoodScreenState();
}

class _EditMoodScreenState extends State<EditMoodScreen> {
  late String _selectedEmoji;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selectedEmoji = widget.initialEmoji;
    _controller = TextEditingController(text: widget.initialReflection);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Mood Entry', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'emoji': _selectedEmoji,
                'reflection': _controller.text.trim(),
              });
            },
            child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHOOSE EMOJI',
              style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widget.emojis.map((emoji) {
                final isSelected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withValues(alpha: 0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.blue : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'REFLECTION',
              style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Update your reflection notes...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}