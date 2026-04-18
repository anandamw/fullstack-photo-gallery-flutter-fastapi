import 'package:flutter/material.dart';

abstract class TileData {
  final String id;
  final String url;
  final Color overlay;

  TileData({
    required this.id,
    required this.url,
    this.overlay = Colors.transparent,
  });

  TileData copyWith({Color? overlay});
}

class ImageData extends TileData {
  final String title;
  final String description;
  final bool comic;
  final String timeCreated;

  ImageData({
    required String id,
    required String url,
    required this.title,
    required this.description,
    required this.comic,
    required this.timeCreated,
    Color overlay = Colors.transparent,
  }) : super(id: id, url: url, overlay: overlay);

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['uuid'] ?? '',
      url: "${json['uuid']}.${json['type']}",
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      comic: json['comic'] == 1,
      timeCreated: json['time_created'] ?? '',
    );
  }

  @override
  ImageData copyWith({Color? overlay}) {
    return ImageData(
      id: id,
      url: url,
      title: title,
      description: description,
      comic: comic,
      timeCreated: timeCreated,
      overlay: overlay ?? this.overlay,
    );
  }
}

class TagData extends TileData {
  final String name;

  TagData({
    required String id,
    required String url,
    required this.name,
    Color overlay = Colors.transparent,
  }) : super(id: id, url: url, overlay: overlay);

  factory TagData.fromJson(Map<String, dynamic> json) {
    return TagData(
      id: json['tname'] ?? '',
      name: json['tname'] ?? '',
      url: "${json['uuid']}.${json['type']}",
    );
  }

  @override
  TagData copyWith({Color? overlay}) {
    return TagData(
      id: id,
      url: url,
      name: name,
      overlay: overlay ?? this.overlay,
    );
  }
}
