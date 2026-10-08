import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceCaptureScreen extends StatefulWidget {
  const VoiceCaptureScreen({super.key, required this.onTranscriptReady});

  final ValueChanged<String> onTranscriptReady;

  @override
  State<VoiceCaptureScreen> createState() => _VoiceCaptureScreenState();
}

class _VoiceCaptureScreenState extends State<VoiceCaptureScreen> {
  late final SpeechToText _speechToText;
  CameraController? _cameraController;
  late final Future<void> _cameraReady;

  String _transcript = '';
  bool _isListening = false;
  bool _isStarting = false;
  bool _cameraInitialized = false;
  String _status = 'Starting camera...';

  @override
  void initState() {
    super.initState();
    _speechToText = SpeechToText();
    _cameraReady = _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      final cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No camera is available.');
      }
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      _cameraController = controller;
      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _cameraInitialized = true;
        _status = 'Press Start to begin listening';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = error.toString();
      });
    }
  }

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
    unawaited(_stopListening());
    unawaited(_cameraController?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Voice with Vera'),
      ),
      body: FutureBuilder<void>(
        future: _cameraReady,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Camera could not be started. ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!_cameraInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_cameraController!),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _isListening ? Colors.red : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isListening ? 'Listening' : 'Camera ready',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your words',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 88,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          _transcript.isEmpty
                              ? 'Speak naturally...'
                              : _transcript,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _status,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isStarting || !_cameraInitialized
                            ? null
                            : _toggleListening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening
                              ? Colors.red
                              : Colors.white,
                          foregroundColor: _isListening
                              ? Colors.white
                              : Colors.black,
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
                        onPressed: _transcript.trim().isEmpty
                            ? null
                            : _sendTranscript,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Send to Vera'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
