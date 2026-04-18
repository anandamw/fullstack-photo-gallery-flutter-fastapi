import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gallery_provider.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  bool _compressed = false;
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true, // Required for Web/Desktop
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final dio = ref.read(dioProvider);
      
      final List<MultipartFile> files = [];
      for (var file in result.files) {
        if (file.bytes != null) {
          files.add(MultipartFile.fromBytes(file.bytes!, filename: file.name));
        } else if (file.path != null) {
          files.add(await MultipartFile.fromFile(file.path!, filename: file.name));
        }
      }

      final formData = FormData.fromMap({
        "title": _titleController.text.isEmpty ? " " : _titleController.text,
        "description": _descController.text.isEmpty ? " " : _descController.text,
        "tag": _tagController.text.isEmpty ? " " : _tagController.text,
        "compressed": _compressed,
        "files": files,
      });

      final response = await dio.post('/images/', data: formData);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload Successful!")),
          );
          Navigator.pop(context);
          // Refresh gallery
          ref.read(imageGalleryProvider.notifier).fetchImages(refresh: true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload Failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Images"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagController,
              decoration: const InputDecoration(labelText: "Tag"),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text("Compress Images"),
                Switch(
                  value: _compressed,
                  onChanged: (val) => setState(() => _compressed = val),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_isUploading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _pickAndUpload,
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Select & Upload Files"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
