import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../models/media_item.dart';

class SignageScreen extends StatefulWidget {
  const SignageScreen({super.key});

  @override
  State<SignageScreen> createState() => _SignageScreenState();
}

class _SignageScreenState extends State<SignageScreen> {
  List<MediaItem> _items = [];
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadContentAndStart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  // Loads the JSON content
  Future<void> _loadContentAndStart() async {
    // Load JSON from assets
    final String jsonString = await rootBundle.loadString(
      'assets/contents.json',
    );
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final List<dynamic> results = data['result'];

    _items = results.map((itemJson) => MediaItem.fromJson(itemJson)).toList();
    if (_items.isEmpty) {
      return;
    }

    // Start a timer to switch items every 10 seconds
    _showMediaAtIndex(0);
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      int nextIndex = (_currentIndex + 1) % _items.length;
      _showMediaAtIndex(nextIndex);
    });
  }

  void _showMediaAtIndex(int index) {
    // Dispose previous controller safely
    if (_videoController != null) {
      _videoController!.pause();
      _videoController!.dispose();
      _videoController = null;
    }

    setState(() {
      _currentIndex = index;
    });

    final currentItem = _items[_currentIndex];
    if (currentItem.type == 'video') {
      final uri = Uri.tryParse(currentItem.url);

      if (uri == null) {
        print("Invalid video URL");
        return;
      }

      _videoController = VideoPlayerController.networkUrl(uri);
      _videoController!
          .initialize()
          .then((_) {
            if (!mounted) return;

            _videoController!.play();
            setState(() {});
          })
          .catchError((error) {
            print("Video initialization error: $error");
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentItem = _items[_currentIndex];
    Widget contentWidget;

    // Display full-screen image with proper aspect ratio
    if (currentItem.type == 'image') {
      contentWidget = Image.network(
        currentItem.url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          // Show a loader while the image loads
          return progress == null
              ? child
              : const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          // On error, show a simple error message (could skip instead)
          return const Center(
            child: Icon(Icons.error, color: Colors.red, size: 50),
          );
        },
      );
    } else {
      // Display video or a loading spinner
      if (_videoController != null && _videoController!.value.isInitialized) {
        // contentWidget = AspectRatio(
        //   aspectRatio: _videoController!.value.aspectRatio,
        //   child: VideoPlayer(_videoController!),
        // );
        contentWidget = FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        );
      } else {
        // Video is still initializing
        contentWidget = const Center(child: CircularProgressIndicator());
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [contentWidget]),
    );
  }
}
