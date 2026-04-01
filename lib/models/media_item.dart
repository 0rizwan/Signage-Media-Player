class MediaItem {
  final String type;
  final String url;

  MediaItem({required this.type, required this.url});

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(type: json['type'] as String, url: json['url'] as String);
  }
}
