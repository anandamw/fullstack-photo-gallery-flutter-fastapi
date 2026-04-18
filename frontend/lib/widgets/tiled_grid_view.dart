import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gallery_provider.dart';
import '../widgets/gallery_tile.dart';

class TiledGridView extends ConsumerStatefulWidget {
  final StateNotifierProvider<StateNotifier<GalleryState>, GalleryState> provider;
  final Function(int) onTileTap;

  const TiledGridView({
    super.key,
    required this.provider,
    required this.onTileTap,
  });

  @override
  ConsumerState<TiledGridView> createState() => _TiledGridViewState();
}

class _TiledGridViewState extends ConsumerState<TiledGridView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.provider == imageGalleryProvider) {
        ref.read(imageGalleryProvider.notifier).fetchImages();
      } else if (widget.provider == tagGalleryProvider) {
        ref.read(tagGalleryProvider.notifier).fetchTags();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) {
          return const SizedBox.shrink();
        }
        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: state.items.length + (state.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final item = state.items[index];
            final isSelected = state.selectedIds.contains(item.id);
            return GalleryTile(
              tileData: item,
              isSelected: isSelected,
              onTap: () => widget.onTileTap(index),
            );
          },
        );
      },
    );
  }
}
