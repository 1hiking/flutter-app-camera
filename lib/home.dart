import 'dart:io';

import 'package:ejad/gallery.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _controller;
  List<CameraDescription> cameras = [];
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initSpeech();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller.initialize();
    setState(() {});
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    if (_lastWords.toLowerCase().contains('cheese')) {
      _takePicture();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final XFile file = await _controller.takePicture();
    final supabase = Supabase.instance.client;
    final String path = await supabase.storage.from('images').upload(
        '${supabase.auth.currentUser?.id}/${DateTime.now().millisecondsSinceEpoch}_${_lastWords.toLowerCase()}.jpg',
        File(file.path));
    print('Picture taken: ${file.path}');
  }

  Future<void> _goGallery() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoragePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Camera App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Scaffold(
          appBar: AppBar(title: const Text('Camera Preview')),
          body: _controller.value.isInitialized
              ? CameraPreview(_controller)
              : const Center(child: CircularProgressIndicator()),
          floatingActionButton:
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            FloatingActionButton(
              onPressed: _speechToText.isNotListening
                  ? _startListening
                  : _stopListening,
              tooltip: 'Listen',
              heroTag: null,
              child: Icon(
                  _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            ),
            SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              onPressed: _goGallery,
              tooltip: 'Go to gallery',
              heroTag: null,
              child: const Icon(Icons.collections),
            )
          ]),
        ));
  }
}
