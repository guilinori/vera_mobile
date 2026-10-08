import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MicrophoneCaptureScreen extends StatefulWidget {
  const MicrophoneCaptureScreen({super.key, required this.onTranscriptReady});

  final ValueChanged<String> onTranscriptReady;

  @override
  State<MicrophoneCaptureScreen> createState() =>
      _MicrophoneCaptureScreenState();
}

class _MicrophoneCaptureScreenState extends State<MicrophoneCaptureScreen> {
  final SpeechToText _speechToText = SpeechToText();
  String _transcript = '';
  bool _isListening = false;
  bool _isStarting = false;
  String _status = 'Press Start to begin listening';

  Future<void> _startListening() async {
    if (_isStarting) return;
    setState(() {
      _isStarting = true;
      _status = 'Starting speech recognition...';
    });

    try {
      final initialized = await _speechToText.initialize(
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _status = 'Speech recognition failed: $error';
          });
        },
        onStatus: (status) {
          if (!mounted) return;
          setState(() {
            _isListening = status == SpeechToText.listeningStatus;
          });
        },
      );
      if (!initialized) {
        if (!mounted) return;
        setState(() {
          _isStarting = false;
          _status = 'Speech recognition is not available.';
        });
        return;
      }

      await _speechToText.listen(
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
        ),
        onResult: (result) {
          if (!mounted) return;
          final recognized = result.recognizedWords.trim();
          if (recognized.isEmpty) return;

          setState(() {
            _transcript = recognized;
            _isListening = true;
            _status = 'Listening...';
          });
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _isStarting = false;
        _status = 'Could not start speech recognition: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    await _speechToText.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _status = 'Stopped. Press Start to listen again';
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _sendTranscript() async {
    if (_transcript.trim().isEmpty) return;
    if (_isListening) await _stopListening();
    if (!mounted) return;
    widget.onTranscriptReady(_transcript.trim());
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    unawaited(_speechToText.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('Voice to Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.red : Colors.white12,
                border: Border.all(
                  color: _isListening ? Colors.red : Colors.white54,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.mic,
                size: 48,
                color: _isListening ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _isListening ? 'Listening...' : 'Microphone ready',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _status,
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 130,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  _transcript.isEmpty
                      ? 'Your words will appear here...'
                      : _transcript,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isStarting ? null : _toggleListening,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? Colors.red : Colors.white,
                  foregroundColor: _isListening ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isListening ? 'Stop listening' : 'Start listening',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _transcript.trim().isEmpty ? null : _sendTranscript,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Add to Chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
