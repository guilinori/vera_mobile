import 'dart:async';

import 'package:flutter/material.dart';

class MoodEntryModel {
  String emotionEmoji;
  String reflection;
  DateTime recordedAt;

  MoodEntryModel({
    required this.emotionEmoji,
    required this.reflection,
    required this.recordedAt,
  });
}

class _MoodBarChartPainter extends CustomPainter {
  const _MoodBarChartPainter({
    required this.emojiCounts,
    required this.emojiColors,
    required this.chartHeight,
    required this.maximumCount,
  });

  final List<int> emojiCounts;
  final List<Color> emojiColors;
  final double chartHeight;
  final int maximumCount;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;
    final plotWidth = size.width;
    final plotHeight = chartHeight;
    final maximumCountValue = maximumCount == 0 ? 1 : maximumCount;
    final groupWidth = plotWidth / emojiCounts.length;
    final barWidth = groupWidth > 40 ? 44.0 : 32.0;

    for (var gridLine = 0; gridLine <= 4; gridLine++) {
      final y = plotHeight * gridLine / 4;
      canvas.drawLine(Offset(0, y), Offset(plotWidth, y), gridPaint);
    }

    for (var emojiIndex = 0; emojiIndex < emojiCounts.length; emojiIndex++) {
      final count = emojiCounts[emojiIndex];
      final barHeight = plotHeight * count / maximumCountValue;
      final x = emojiIndex * groupWidth + (groupWidth - barWidth) / 2;
      final y = plotHeight - barHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        Paint()..color = emojiColors[emojiIndex],
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MoodBarChartPainter oldDelegate) {
    return oldDelegate.emojiCounts != emojiCounts ||
        oldDelegate.emojiColors != emojiColors ||
        oldDelegate.chartHeight != chartHeight ||
        oldDelegate.maximumCount != maximumCount;
  }
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
  bool _showCalendar = false;
  DateTime _calendarMonth = DateTime.now();
  DateTime _analyticsMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  Timer? _calendarTapTimer;

  final List<MoodEntryModel> _entries = [
    MoodEntryModel(
      emotionEmoji: '😔',
      reflection: 'I am tired, coding I want to eat tamal',
      recordedAt: DateTime(2026, 10, 5, 22, 48),
    ),
    MoodEntryModel(
      emotionEmoji: '😊',
      reflection: 'Feeling productive today working on Flutter!',
      recordedAt: DateTime(2026, 10, 3, 14, 15),
    ),
  ];

  final List<String> _emojis = ['😊', '😔', '🥳', '😡', '😰', '😴', '🤩'];

  void _recordEntry() {
    final text = _reflectionController.text.trim();
    final now = DateTime.now();
    final recordedAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
    );

    setState(() {
      _entries.insert(
        0,
        MoodEntryModel(
          emotionEmoji: _selectedEmoji,
          reflection: text.isEmpty ? 'No reflection provided.' : text,
          recordedAt: recordedAt,
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

  String _formatDate(DateTime date) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final displayHour = (date.hour % 12).toString().padLeft(2, '0');
    final normalizedHour = displayHour == '00' ? '12' : displayHour;

    return '$normalizedHour:$minute $period';
  }

  String _formatMonthYear(DateTime date) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${monthNames[date.month - 1]} ${date.year}';
  }

  void _changeSelectedDay(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _calendarMonth = DateTime(_selectedDate.year, _selectedDate.month);
      _analyticsMonth = DateTime(_selectedDate.year, _selectedDate.month);
    });
  }

  void _changeCalendarMonth(int monthOffset) {
    final targetMonth = DateTime(
      _calendarMonth.year,
      _calendarMonth.month + monthOffset,
    );
    final targetDay = _selectedDate.day.clamp(
      1,
      DateTime(targetMonth.year, targetMonth.month + 1, 0).day,
    );

    setState(() {
      _selectedDate = DateTime(targetMonth.year, targetMonth.month, targetDay);
      _calendarMonth = targetMonth;
      _analyticsMonth = targetMonth;
    });
  }

  void _handleCalendarDayTap(DateTime date) {
    if (_calendarTapTimer != null) {
      _calendarTapTimer!.cancel();
      _calendarTapTimer = null;
      setState(() {
        _showCalendar = false;
      });
      return;
    }

    setState(() {
      _selectedDate = date;
      _calendarMonth = DateTime(date.year, date.month);
      _analyticsMonth = DateTime(date.year, date.month);
    });
    _calendarTapTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _calendarTapTimer = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _calendarTapTimer?.cancel();
    _reflectionController.dispose();
    super.dispose();
  }

  void _showYearPicker() {
    final currentYear = DateTime.now().year;
    final availableYears = List<int>.generate(
      currentYear - 1900 + 1,
      (index) => currentYear - index,
    );
    int selectedYear = _calendarMonth.year;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select a year'),
              content: SizedBox(
                width: 180,
                child: DropdownButtonFormField<int>(
                  initialValue: selectedYear,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: availableYears
                      .map(
                        (year) => DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (year) {
                    if (year != null) {
                      setDialogState(() => selectedYear = year);
                    }
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedYear != _calendarMonth.year) {
                      setState(() {
                        _calendarMonth = DateTime(
                          selectedYear,
                          _calendarMonth.month,
                        );
                        _selectedDate = DateTime(
                          selectedYear,
                          _calendarMonth.month,
                          1,
                        );
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAnalyticsMonthPicker() async {
    final monthNames = const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final years = List<int>.generate(2100 - 1900 + 1, (index) => 1900 + index);
    var selectedMonth = _analyticsMonth.month - 1;
    var selectedYear = _analyticsMonth.year;

    final result = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select analytics month'),
              content: SizedBox(
                width: 220,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                      ),
                      items: List<DropdownMenuItem<int>>.generate(
                        12,
                        (index) => DropdownMenuItem<int>(
                          value: index,
                          child: Text(monthNames[index]),
                        ),
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedMonth = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      items: years
                          .map(
                            (year) => DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedYear = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      DateTime(selectedYear, selectedMonth + 1),
                    );
                  },
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _analyticsMonth = result);
    }
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<MoodEntryModel> _entriesForDate(DateTime date) {
    return _entries
        .where((entry) => _isSameDay(entry.recordedAt, date))
        .toList();
  }

  List<Widget> _buildCalendar() {
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final lastDay = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday;
    final calendarDays = <DateTime>[];

    for (var day = 1; day <= lastDay.day; day++) {
      calendarDays.add(
        DateTime(_calendarMonth.year, _calendarMonth.month, day),
      );
    }

    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final calendarCells = <Widget>[];

    for (var i = 0; i < firstWeekday - DateTime.monday; i++) {
      calendarCells.add(const SizedBox.shrink());
    }

    for (final date in calendarDays) {
      final entries = _entriesForDate(date);
      final isSelected = _isSameDay(date, _selectedDate);
      final isToday = _isSameDay(date, DateTime.now());
      final moodCountLabel = entries.length == 1
          ? '1 mood entry'
          : '${entries.length} mood entries';

      calendarCells.add(
        Semantics(
          button: true,
          enabled: true,
          label: moodCountLabel,
          child: SizedBox(
            key: Key('calendar-day-${date.year}-${date.month}-${date.day}'),
            height: 60,
            child: Material(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => _handleCalendarDayTap(date),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.black87,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (entries.isNotEmpty)
                        SizedBox(
                          width: 60,
                          height: 24,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: entries
                                .take(3)
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                                  final mood = entry.value;
                                  final offset = entry.key * 7;

                                  return Positioned(
                                    left: offset.toDouble(),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      padding: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? Colors.blue
                                            : _emotionColor(mood.emotionEmoji)
                                                  .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        mood.emotionEmoji,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Previous month',
            onPressed: () => _changeCalendarMonth(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: TextButton(
              onPressed: _showYearPicker,
              child: Text(
                _formatMonthYear(_calendarMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next month',
            onPressed: () => _changeCalendarMonth(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: weekdayNames
            .map(
              (weekday) => Expanded(
                child: Text(
                  weekday,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 8),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: 0.85,
        children: calendarCells,
      ),
      const SizedBox(height: 24),
      _buildSelectedDateDetails(),
    ];
  }

  Widget _buildSelectedDateDetails() {
    final entries = _entriesForDate(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(_selectedDate),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'No mood entry recorded for this day.',
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          ...entries.map((entry) {
            final index = _entries.indexOf(entry);
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
                      Text(
                        entry.emotionEmoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _navigateToEditScreen(index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.redAccent,
                            ),
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
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(entry.recordedAt),
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Color _emotionColor(String emoji) {
    switch (emoji) {
      case '😊':
        return Colors.green;
      case '😔':
        return Colors.blue;
      case '🥳':
        return Colors.amber;
      case '😡':
        return Colors.red;
      case '😰':
        return Colors.deepPurple;
      case '😴':
        return Colors.grey;
      case '🤩':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmotionFrequencyChart(DateTime selectedMonth) {
    final chartHeight = 160.0;
    final emojiCounts = _emojis.map((emoji) {
      return _entries
          .where(
            (entry) =>
                entry.recordedAt.year == selectedMonth.year &&
                entry.recordedAt.month == selectedMonth.month &&
                entry.emotionEmoji == emoji,
          )
          .length;
    }).toList();
    final emojiColors = _emojis.map(_emotionColor).toList();
    final maximumCount = emojiCounts.fold(
      0,
      (currentMaximum, count) =>
          count > currentMaximum ? count : currentMaximum,
    );
    final dominantMoodIndex = emojiCounts.indexOf(maximumCount);
    final dominantMood = maximumCount > 0 ? _emojis[dominantMoodIndex] : null;
    final chartLabels = _emojis.asMap().entries.map((entry) {
      final emoji = entry.value;
      final count = emojiCounts[entry.key];
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 3),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }).toList();

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final chartWidth = constraints.maxWidth;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emotion Frequency by Month',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    key: const Key('emotion-chart'),
                    height: chartHeight,
                    child: CustomPaint(
                      size: Size(chartWidth, chartHeight),
                      painter: _MoodBarChartPainter(
                        emojiCounts: emojiCounts,
                        emojiColors: emojiColors,
                        chartHeight: chartHeight,
                        maximumCount: maximumCount,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 42.0,
                    child: Row(
                      children: List<Expanded>.generate(
                        _emojis.length,
                        (index) => Expanded(child: chartLabels[index]),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildDominantMoodContainer(dominantMood),
      ],
    );
  }

  Widget _buildDominantMoodContainer(String? dominantMood) {
    return Container(
      key: const Key('dominant-mood-container'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        dominantMood == null
            ? 'No dominant mood'
            : 'Dominant mood: $dominantMood',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _buildGroupedEntries() {
    final sortedEntries = List<MoodEntryModel>.from(
      _entriesForDate(_selectedDate),
    )..sort((first, second) => second.recordedAt.compareTo(first.recordedAt));
    final groupedEntries = <String, List<Map<String, dynamic>>>{};

    for (final entry in sortedEntries) {
      final monthKey =
          '${entry.recordedAt.year}-${entry.recordedAt.month.toString().padLeft(2, '0')}';
      groupedEntries.putIfAbsent(monthKey, () => []).add({
        'entry': entry,
        'index': _entries.indexOf(entry),
      });
    }

    return groupedEntries.entries.map((group) {
      final groupDate = sortedEntries
          .firstWhere(
            (entry) =>
                '${entry.recordedAt.year}-${entry.recordedAt.month.toString().padLeft(2, '0')}' ==
                group.key,
          )
          .recordedAt;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: Text(
              _formatMonthYear(groupDate),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ...group.value.map((item) {
            final entry = item['entry'] as MoodEntryModel;
            final index = item['index'] as int;

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
                      Text(
                        entry.emotionEmoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Colors.black54,
                            ),
                            onPressed: () => _navigateToEditScreen(index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.redAccent,
                            ),
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
                      Text(
                        _formatDate(entry.recordedAt),
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _formatTime(entry.recordedAt),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }).toList();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mood Log',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showCalendar ? Icons.calendar_today : Icons.calendar_month,
              color: Colors.black87,
            ),
            onPressed: () => setState(() {
              _showCalendar = !_showCalendar;
              _showAnalytics = false;
            }),
          ),
          IconButton(
            icon: Icon(
              _showAnalytics ? Icons.list : Icons.analytics_outlined,
              color: Colors.black87,
            ),
            onPressed: () => setState(() {
              _showAnalytics = !_showAnalytics;
              _showCalendar = false;
            }),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_entries.length}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Total Logs',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_entries.where((entry) => entry.recordedAt.year == _analyticsMonth.year && entry.recordedAt.month == _analyticsMonth.month).length}',
                            key: Key(
                              'monthly-log-count-${_analyticsMonth.year}-${_analyticsMonth.month}',
                            ),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Logs This Month',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_showCalendar) ...[
                ..._buildCalendar(),
              ] else if (_showAnalytics) ...[
                const Text(
                  'MOOD ANALYTICS & FREQUENCY',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Previous month',
                      onPressed: () => setState(() {
                        _analyticsMonth = DateTime(
                          _analyticsMonth.year,
                          _analyticsMonth.month - 1,
                        );
                      }),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _showAnalyticsMonthPicker,
                        icon: const Icon(Icons.edit_calendar_outlined),
                        label: Text(
                          _formatMonthYear(_analyticsMonth),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Next month',
                      onPressed: () => setState(() {
                        _analyticsMonth = DateTime(
                          _analyticsMonth.year,
                          _analyticsMonth.month + 1,
                        );
                      }),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildEmotionFrequencyChart(_analyticsMonth),
              ] else ...[
                const Text(
                  'LOG HOW YOU FEEL',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
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
                          color: isSelected
                              ? Colors.blue.withValues(alpha: 0.2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Previous day',
                      onPressed: () => _changeSelectedDay(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Semantics(
                        button: true,
                        enabled: true,
                        label: 'Open calendar to choose a date',
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showCalendar = true;
                              _showAnalytics = false;
                            });
                          },
                          child: Text(
                            _formatDate(_selectedDate),
                            key: const Key('entry-date-navigation'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Next day',
                      onPressed: () => _changeSelectedDay(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _recordEntry,
                    child: const Text(
                      'Record Entry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'REAL-TIME ACTIVITY HISTORY',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),

                if (_entriesForDate(_selectedDate).isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      'No mood entries for ${_formatDate(_selectedDate)}.',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  ..._buildGroupedEntries(),
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
        title: const Text(
          'Edit Mood Entry',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'emoji': _selectedEmoji,
                'reflection': _controller.text.trim(),
              });
            },
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
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
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
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
                      color: isSelected
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'REFLECTION',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
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
