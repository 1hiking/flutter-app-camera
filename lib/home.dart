import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();

    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void takePicture() async {
    final XFile file = await _controller.takePicture();
    // Do something with the picture file
    print('Picture taken: ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Preview'),
      ),
      body: CameraPreview(_controller),
      floatingActionButton: FloatingActionButton(
        onPressed: takePicture,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
