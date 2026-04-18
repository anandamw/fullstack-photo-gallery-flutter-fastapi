import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/image_models.dart';
import '../core/backend_config.dart';

class GalleryTile extends StatelessWidget {
  final TileData tileData;
  final VoidCallback onTap;
  final double thumbnailSize;
  final bool isSelected;

  const GalleryTile({
    super.key,
    required this.tileData,
    required this.onTap,
    this.thumbnailSize = 200,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: "${BackendConfig.baseUrl}/t/${tileData.url}",
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          if (tileData.overlay != Colors.transparent || isSelected)
            Positioned.fill(
              child: Container(
                color: isSelected 
                  ? Colors.blue.withOpacity(0.4) 
                  : tileData.overlay,
                child: isSelected 
                  ? const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 40))
                  : null,
              ),
            ),
          if (tileData is TagData)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                color: Colors.black.withOpacity(0.5),
                child: Text(
                  (tileData as TagData).name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
