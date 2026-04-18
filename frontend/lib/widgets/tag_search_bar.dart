import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gallery_provider.dart';

class TagSearchBar extends ConsumerWidget {
  final Function(String) onTagSelected;
  final String? initialValue;

  const TagSearchBar({
    super.key,
    required this.onTagSelected,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dio = ref.watch(dioProvider);

    return TypeAheadField<String>(
      builder: (context, controller, focusNode) {
        if (initialValue != null && controller.text.isEmpty) {
          controller.text = initialValue!;
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search by tag...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) onTagSelected(value);
          },
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.isEmpty) return [];
        try {
          final response = await dio.get('/autocomplete', queryParameters: {'tag_start': pattern});
          if (response.statusCode == 200) {
            final List<dynamic> tags = response.data['tags'];
            return tags.map((t) => t.toString()).toList();
          }
        } catch (e) {
          print("Autocomplete error: $e");
        }
        return [];
      },
      itemBuilder: (context, String suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSelected: (suggestion) {
        onTagSelected(suggestion);
      },
    );
  }
}
