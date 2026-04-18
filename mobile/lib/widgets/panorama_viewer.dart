import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

class MyPanoramaViewer extends StatefulWidget {
  final ImageProvider image;
  const MyPanoramaViewer({super.key, required this.image});

  @override
  State<MyPanoramaViewer> createState() => _MyPanoramaViewerState();
}

class _MyPanoramaViewerState extends State<MyPanoramaViewer> {
  bool _animated = true;
  bool _isDesktop = !(defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      onDoubleTap: () {
        setState(() {
          _animated = !_animated;
        });
      },
      child: PanoramaViewer(
        minZoom: 0.1,
        maxZoom: 20,
        sensorControl: _isDesktop ? SensorControl.none : SensorControl.orientation,
        sensitivity: 1.5,
        animSpeed: _animated ? 14 : 0,
        zoom: 0.7,
        child: Image(image: widget.image),
      ),
    );
  }
}
