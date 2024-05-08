import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _controller;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void takePicture() async {
    final XFile file = await _controller.takePicture();
    final supabase = Supabase.instance.client;
    final String path = await supabase.storage.from('images').upload(
        '${supabase.auth.currentUser?.id}/${DateTime.now().millisecondsSinceEpoch}.jpg',
        File(file.path));

    print('Picture taken: ${file.path}');
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
        floatingActionButton: FloatingActionButton(
          onPressed: takePicture,
          child: const Icon(Icons.camera),
        ),
      ),
    );
  }
}
