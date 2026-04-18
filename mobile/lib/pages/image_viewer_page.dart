import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gallery_provider.dart';
import '../widgets/tiled_grid_view.dart';
import '../widgets/image_popup.dart';
import '../models/image_models.dart';

class ImageViewerPage extends ConsumerWidget {
  final String? tag;

  const ImageViewerPage({super.key, this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set tag and fetch if it's new
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(imageGalleryProvider).currentTag != tag) {
        ref.read(imageGalleryProvider.notifier).setTag(tag);
      }
    });

    final state = ref.watch(imageGalleryProvider);
    final isSelectionMode = state.isSelectionMode;

    return Scaffold(
      appBar: isSelectionMode 
        ? AppBar(
            title: Text("${state.selectedIds.length} Selected"),
            backgroundColor: Colors.blueGrey,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(imageGalleryProvider.notifier).setSelectionMode(false),
            ),
            actions: [
              if (state.selectedIds.length == 2 && tag != null)
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: "Swap Positions",
                  onPressed: () => _handleSwap(context, ref),
                ),
              IconButton(
                icon: const Icon(Icons.label),
                tooltip: "Tag Selected",
                onPressed: () => _handleBatchTag(context, ref),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: "Delete Selected",
                onPressed: () => _handleDelete(context, ref),
              ),
            ],
          )
        : AppBar(
            title: Text(tag ?? "All Images"),
            backgroundColor: Colors.orange,
            actions: [
              IconButton(
                icon: const Icon(Icons.check_box_outline_blank),
                tooltip: "Selection Mode",
                onPressed: () => ref.read(imageGalleryProvider.notifier).setSelectionMode(true),
              ),
              DropdownButton<SortMode>(
                value: state.sortMode,
                icon: const Icon(Icons.sort, color: Colors.white),
// ... (rest of the app bar logic)
            dropdownColor: Colors.orange,
            underline: Container(),
            onChanged: (SortMode? newValue) {
              if (newValue != null) {
                ref.read(imageGalleryProvider.notifier).setSortMode(newValue);
              }
            },
            items: SortMode.values.map((SortMode mode) {
              return DropdownMenuItem<SortMode>(
                value: mode,
                child: Text(
                  mode.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(imageGalleryProvider.notifier).fetchImages(refresh: true),
          ),
        ],
      ),
      body: TiledGridView(
        provider: imageGalleryProvider,
        onTileTap: (index) {
          final item = ref.read(imageGalleryProvider).items[index];
          if (isSelectionMode) {
            ref.read(imageGalleryProvider.notifier).toggleSelection(item.id);
          } else {
            final items = ref.read(imageGalleryProvider).items.whereType<ImageData>().toList();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImagePopup(images: items, initialIndex: index)),
            );
          }
        },
      ),
    );
  }

  void _handleDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Images"),
        content: const Text("Are you sure you want to delete the selected images?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(imageGalleryProvider.notifier).batchDelete();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleBatchTag(BuildContext context, WidgetRef ref) {
    String newTag = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Tag to Selected"),
        content: TextField(
          decoration: const InputDecoration(hintText: "Enter tag name"),
          onChanged: (val) => newTag = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (newTag.isNotEmpty) {
                ref.read(imageGalleryProvider.notifier).batchTag(newTag);
              }
              Navigator.pop(context);
            },
            child: const Text("Add Tag"),
          ),
        ],
      ),
    );
  }

  void _handleSwap(BuildContext context, WidgetRef ref) {
    ref.read(imageGalleryProvider.notifier).swapImages();
  }
}
