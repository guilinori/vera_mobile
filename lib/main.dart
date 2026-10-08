import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'breathing_screen.dart';
import 'mood_log_screen.dart';
import 'microphone_capture_screen.dart';
import 'voice_capture_screen.dart';

void main() {
  runApp(const VeraApp());
}

class VeraApp extends StatelessWidget {
  const VeraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vera Ai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatSession {
  String title;
  List<ChatMessage> messages;

  ChatSession({required this.title, required this.messages});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  // Configure GROQ_API_KEY in the Flutter build environment.
  final String _groqApiKey = "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";

  // Manage sessions dynamically
  final List<ChatSession> _sessions = [
    ChatSession(title: 'hello', messages: []),
    ChatSession(title: 'Dealing with academic stress', messages: []),
    ChatSession(title: 'Evening reflection', messages: []),
  ];

  int _currentSessionIndex = 0;

  List<ChatMessage> get _messages => _sessions[_currentSessionIndex].messages;

  Future<void> _callGroqApi(String prompt) async {
    if (_groqApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configure the Groq API key before sending a message.'),
        ),
      );
      return;
    }

    final isFirstMessage = _messages.isEmpty;

    setState(() {
      _isLoading = true;
      _messages.add(ChatMessage(text: prompt, isUser: true));
    });
    _controller.clear();

    if (isFirstMessage) {
      _sessions[_currentSessionIndex].title = prompt.length > 25
          ? '${prompt.substring(0, 22)}...'
          : prompt;
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          "model": "openai/gpt-oss-20b",
          "messages": [
            {
              "role": "system",
              "content": "You are Vera, an ambient, on-demand supportive companion and conversational listener. Strictly adhere to active listening techniques: validate feelings, paraphrase key concerns, and ask gentle open-ended questions. Avoid transactional advice.",
            },
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiReply = data['choices'][0]['message']['content'];
        setState(() {
          _messages.add(ChatMessage(text: aiReply, isUser: false));
        });
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              text:
                  'Error connecting to Vera AI server. (Code: ${response.statusCode})',
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Error connecting to Vera AI server.',
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startNewSession() {
    setState(() {
      _sessions.insert(0, ChatSession(title: 'New Session', messages: []));
      _currentSessionIndex = 0;
    });
    Navigator.pop(context);
  }

  void _renameSession(int index) {
    final TextEditingController renameController = TextEditingController(
      text: _sessions[index].title,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Session'),
        content: TextField(
          controller: renameController,
          decoration: const InputDecoration(hintText: 'Enter new session name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _sessions[index].title = renameController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteSession(int index) {
    setState(() {
      _sessions.removeAt(index);
      if (_sessions.isEmpty) {
        _sessions.add(ChatSession(title: 'New Session', messages: []));
      }
      if (_currentSessionIndex >= _sessions.length) {
        _currentSessionIndex = _sessions.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Open drawer',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu_rounded),
        ),
        title: Text(
          'Vera Ai - ${_sessions[_currentSessionIndex].title}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        key: const Key('drawer-content'),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.only(
                top: 100,
                bottom: 18,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Vera AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Supportive Conversational Listener',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Color(0xFF0F172A)),
              title: const Text(
                'New Session',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: _startNewSession,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.air, color: Colors.teal),
              title: const Text('Breathing Exercise'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BreathingScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.mood, color: Colors.blueAccent),
              title: const Text('Mood Log'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoodLogScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'RECENT',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ..._sessions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final session = entry.value;
                    final isSelected = _currentSessionIndex == index;
                    return ListTile(
                      tileColor: isSelected ? Colors.grey.shade100 : null,
                      title: Text(
                        session.title,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: () => _renameSession(index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteSession(index),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _currentSessionIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            ),
            Container(
              key: const Key('drawer-footer'),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Profile',
                    icon: const Icon(Icons.person_outline),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile is coming soon.'),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings are coming soon.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Start a conversation with Vera...',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return Align(
                          alignment: message.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: message.isUser
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              border: message.isUser
                                  ? null
                                  : Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: message.isUser
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ask Vera Ai',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _callGroqApi(value.trim());
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white54,
                        ),
                        tooltip: 'Open camera and listen',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VoiceCaptureScreen(
                              onTranscriptReady: (transcript) {
                                _controller.text = transcript;
                                _callGroqApi(transcript);
                              },
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic_none, color: Colors.white54),
                        tooltip: 'Open microphone and transcribe',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MicrophoneCaptureScreen(
                              onTranscriptReady: (transcript) {
                                _controller.text = transcript;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          if (_controller.text.trim().isNotEmpty) {
                            _callGroqApi(_controller.text.trim());
                          }
                        },
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
