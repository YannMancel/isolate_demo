import 'package:flutter/material.dart';

@immutable
class Photo {
  const Photo._({
    required this.albumId,
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo._(
      albumId: json['albumId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }

  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;
}
