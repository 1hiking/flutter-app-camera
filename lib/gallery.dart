import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoragePage extends StatefulWidget {
  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<String> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final response = await _supabaseClient.storage
          .from('images')
          .list(path: '${_supabaseClient.auth.currentUser?.id}/');

      setState(() {
        _files = response.map((item) => item.name).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading files: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supabase Storage'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_files[index]),
                  onTap: () => _downloadFile(_files[index]),
                );
              },
            ),
    );
  }

  Future<void> _downloadFile(String fileName) async {
    try {
      final response = await _supabaseClient.storage
          .from('your-bucket-name')
          .download(fileName);

      // Handle the file download response (e.g., save to local storage, display, etc.)
      // This is a simplified example, adjust according to your requirements
    } catch (e) {
      print('Error downloading file: $e');
    }
  }
}
