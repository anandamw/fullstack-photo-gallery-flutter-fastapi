import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/image_models.dart';
import '../core/backend_config.dart';

final dioProvider = Provider((ref) => Dio(BaseOptions(baseUrl: BackendConfig.baseUrl)));

enum SortMode { date, dateReverse, position, random, popularity }

class GalleryState {
  final List<TileData> items;
  final bool isLoading;
  final int offset;
  final SortMode sortMode;
  final String? currentTag;
  final bool isSelectionMode;
  final Set<String> selectedIds;

  GalleryState({
    this.items = const [],
    this.isLoading = false,
    this.offset = 0,
    this.sortMode = SortMode.dateReverse,
    this.currentTag,
    this.isSelectionMode = false,
    this.selectedIds = const {},
  });

  GalleryState copyWith({
    List<TileData>? items,
    bool? isLoading,
    int? offset,
    SortMode? sortMode,
    String? currentTag,
    bool? isSelectionMode,
    Set<String>? selectedIds,
  }) {
    return GalleryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      offset: offset ?? this.offset,
      sortMode: sortMode ?? this.sortMode,
      currentTag: currentTag ?? this.currentTag,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class ImageGalleryNotifier extends StateNotifier<GalleryState> {
  final Dio _dio;
  static const int fetchLimit = 20;

  ImageGalleryNotifier(this._dio) : super(GalleryState()) {
    fetchImages();
  }

  // ... (getSortModeString remains the same)

  void setSelectionMode(bool value) {
    state = state.copyWith(isSelectionMode: value, selectedIds: {});
  }

  void toggleSelection(String id) {
    final newSelected = Set<String>.from(state.selectedIds);
    if (newSelected.contains(id)) {
      newSelected.remove(id);
    } else {
      newSelected.add(id);
    }
    state = state.copyWith(selectedIds: newSelected);
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }

  Future<void> batchDelete() async {
    if (state.selectedIds.isEmpty) return;
    
    state = state.copyWith(isLoading: true);
    try {
      for (var id in state.selectedIds) {
        await _dio.delete('/image/$id');
      }
      // Remove locally
      final newItems = state.items.where((item) => !state.selectedIds.contains(item.id)).toList();
      state = state.copyWith(items: newItems, selectedIds: {}, isSelectionMode: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Batch delete failed: $e");
    }
  }

  Future<void> batchTag(String tag, {bool add = true}) async {
    if (state.selectedIds.isEmpty) return;
    
    state = state.copyWith(isLoading: true);
    try {
      final endpoint = add ? '/tag/' : '/untag/';
      final formData = FormData.fromMap({
        'tag': tag,
        'images': state.selectedIds.toList(),
      });
      await _dio.post(endpoint, data: formData);
      
      state = state.copyWith(selectedIds: {}, isSelectionMode: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Batch tagging failed: $e");
    }
  }

  Future<void> swapImages() async {
    if (state.selectedIds.length != 2 || state.currentTag == null) return;
    
    final ids = state.selectedIds.toList();
    state = state.copyWith(isLoading: true);
    try {
      await _dio.put(
        '/reorder/${state.currentTag}/${ids[0]}',
        queryParameters: {'uuid_destination': ids[1], 'mode': 1},
      );
      // Refresh to show new order
      fetchImages(refresh: true);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Swap failed: $e");
    }
  }

  String _getSortModeString(SortMode mode) {
// ...
    switch (mode) {
      case SortMode.date: return "DATE";
      case SortMode.dateReverse: return "MOST_RECENT";
      case SortMode.position: return "POSITION";
      case SortMode.random: return "RANDOM";
      case SortMode.popularity: return "POPULARITY";
    }
  }

  Future<void> fetchImages({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(items: [], offset: 0, isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final queryParams = {
        'sort_mode': _getSortModeString(state.sortMode),
      };
      if (state.currentTag != null) {
        queryParams['tag'] = state.currentTag!;
      }

      final response = await _dio.get(
        '/imagelist/$fetchLimit/${state.offset}',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'];
        final List<ImageData> newItems = data.values
            .map((json) => ImageData.fromJson(json))
            .toList();

        state = state.copyWith(
          items: [...state.items, ...newItems],
          offset: state.offset + fetchLimit,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Error fetching images: $e");
    }
  }

  void setTag(String? tag) {
    state = state.copyWith(currentTag: tag);
    fetchImages(refresh: true);
  }

  void setSortMode(SortMode mode) {
    state = state.copyWith(sortMode: mode);
    fetchImages(refresh: true);
  }
}

final imageGalleryProvider = StateNotifierProvider<ImageGalleryNotifier, GalleryState>((ref) {
  return ImageGalleryNotifier(ref.watch(dioProvider));
});

class TagGalleryNotifier extends StateNotifier<GalleryState> {
  final Dio _dio;
  static const int fetchLimit = 20;

  TagGalleryNotifier(this._dio) : super(GalleryState()) {
    fetchTags();
  }

  Future<void> fetchTags({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(items: [], offset: 0, isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final response = await _dio.get(
        '/taglist/$fetchLimit/${state.offset}',
        queryParameters: {'sort_mode': 'POPULARITY'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'];
        final List<TagData> newItems = data.values
            .map((json) => TagData.fromJson(json))
            .toList();

        state = state.copyWith(
          items: [...state.items, ...newItems],
          offset: state.offset + fetchLimit,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Error fetching tags: $e");
    }
  }
}

final tagGalleryProvider = StateNotifierProvider<TagGalleryNotifier, GalleryState>((ref) {
  return TagGalleryNotifier(ref.watch(dioProvider));
});
