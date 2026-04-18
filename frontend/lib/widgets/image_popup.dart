import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../models/image_models.dart';
import '../core/backend_config.dart';

class ImagePopup extends StatefulWidget {
  final List<ImageData> images;
  final int initialIndex;

  const ImagePopup({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImagePopup> createState() => _ImagePopupState();
}

class _ImagePopupState extends State<ImagePopup> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.images.length,
            builder: (context, index) {
              final image = widget.images[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage("${BackendConfig.baseUrl}/f/${image.url}"),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: image.id),
              );
            },
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
          
          // Back button (like AppBar)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Left Arrow Overlays
          if (_currentIndex > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: GestureDetector(
                  onTap: _goToPrevious,
                  child: Container(
                    width: 70,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_arrow, color: Colors.lightGreenAccent, size: 30, textDirection: TextDirection.rtl),
                    ),
                  ),
                ),
              ),
            ),

          // Right Arrow Overlays
          if (_currentIndex < widget.images.length - 1)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: _goToNext,
                  child: Container(
                    width: 70,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_arrow, color: Colors.lightGreenAccent, size: 30),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
