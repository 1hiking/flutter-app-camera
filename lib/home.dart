import 'dart:io';

import 'package:ejad/gallery.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'voicecommandsscreen.dart'; 

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

    // Mapa de comandos de voz a funciones de acción
    Map<String, Function> voiceCommands = {
      'llanta lateral izquierda': _takePictureLlantaLateralIzquierda,
      'llanta lateral derecha': _takePictureLlantaLateralDerecha,
      'llanta trasera izquierda': _takePictureLlantaTraseraIzquierda,
      'llanta trasera derecha': _takePictureLlantaTraseraDerecha,
      'motor': _takePictureMotor,
      'puerta delantera derecha': _takePicturePuertaDelanteraDerecha,
      'puerta delantera izquierda': _takePicturePuertaDelanteraIzquierda,
      'puerta trasera derecha': _takePicturePuertaTraceraDerecha,
      'puerta trasera izquierda': _takePicturePuertaTraceraIzquierda,
    };

    // Convertir las palabras reconocidas a minúsculas para una comparación más sencilla
    String recognizedWords = _lastWords.toLowerCase();

    voiceCommands.forEach((command, action) {
      if (recognizedWords.contains(command)) {
        action();
      }
    });
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
  }

  // Código donde se toman fotos de las partes del auto
  Future<void> _takePictureLlantaLateralIzquierda() async {
    _takePicture();
  }

  Future<void> _takePictureLlantaLateralDerecha() async {
    _takePicture();
  }

  Future<void> _takePictureLlantaTraseraIzquierda() async {
    _takePicture();
  }

  Future<void> _takePictureLlantaTraseraDerecha() async {
    _takePicture();
  }

  Future<void> _takePictureMotor() async {
    _takePicture();
  }

  Future<void> _takePicturePuertaDelanteraDerecha() async {
    _takePicture();
  }

  Future<void> _takePicturePuertaDelanteraIzquierda() async {
    _takePicture();
  }

  Future<void> _takePicturePuertaTraceraDerecha() async {
    _takePicture();
  }

  Future<void> _takePicturePuertaTraceraIzquierda() async {
    _takePicture();
  }

  Future<void> _goGallery() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StoragePage()),
    );
  }

  void _goToVoiceCommands() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VoiceCommandsScreen()),
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
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: _speechToText.isNotListening
                  ? _startListening
                  : _stopListening,
              tooltip: 'Listen',
              heroTag: null,
              child: Icon(
                  _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: _goGallery,
              tooltip: 'Go to gallery',
              heroTag: null,
              child: const Icon(Icons.collections),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: _goToVoiceCommands,
              tooltip: 'Voice Commands',
              heroTag: null,
              child: const Icon(Icons.list),
            ),
          ],
        ),
      ),
    );
  }
}
