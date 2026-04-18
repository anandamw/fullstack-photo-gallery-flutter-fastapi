import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gallery_provider.dart';
import '../widgets/tiled_grid_view.dart';
import 'image_viewer_page.dart';
import 'upload_page.dart';
import '../models/image_models.dart';
import '../widgets/tag_search_bar.dart';

class TagViewerPage extends ConsumerWidget {
  const TagViewerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: TagSearchBar(
          onTagSelected: (tag) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImageViewerPage(tag: tag)),
            );
          },
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(tagGalleryProvider.notifier).fetchTags(refresh: true),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UploadPage()),
            ),
          ),
        ],
      ),
      body: TiledGridView(
        provider: tagGalleryProvider,
        onTileTap: (index) {
          final tag = ref.read(tagGalleryProvider).items[index] as TagData;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewerPage(tag: tag.name),
            ),
          );
        },
      ),
    );
  }
}
