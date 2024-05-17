import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final response = await _supabaseClient.storage
          .from('images')
          .list(path: '${_supabaseClient.auth.currentUser?.id}/');

      final urls = await Future.wait(response.map((item) async {
        final filePath = '${_supabaseClient.auth.currentUser?.id}/${item.name}';
        final urlResponse = await _supabaseClient.storage
            .from('images')
            .createSignedUrl(filePath, 60);
        return urlResponse;
      }).toList());

      setState(() {
        _imageUrls = urls;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading images: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Storage Gallery'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _downloadFile(_imageUrls[index]),
                  child: Image.network(_imageUrls[index], fit: BoxFit.cover),
                );
              },
            ),
    );
  }

  Future<void> _downloadFile(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      final response = await _supabaseClient.storage
          .from('images')
          .download(uri.pathSegments.last);

      // Handle the file download response (e.g., save to local storage, display, etc.)
      // This is a simplified example, adjust according to your requirements
    } catch (e) {
      print('Error downloading file: $e');
    }
  }
}
