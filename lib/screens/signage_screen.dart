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

  VideoPlayerController? _currentController;
  VideoPlayerController? _nextController;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _currentController?.dispose();
    _nextController?.dispose();
    super.dispose();
  }

  // loading and preparing content
  Future<void> _init() async {
    final jsonString = await rootBundle.loadString('assets/contents.json');
    final data = jsonDecode(jsonString);

    final List list = data['result'];
    _items = list.map((e) => MediaItem.fromJson(e)).toList();

    for (var item in _items) {
      if (item.type == 'image') {
        await precacheImage(NetworkImage(item.url), context);
      }
    }

    await _prepareInitialMedia();

    // 10sec duration timer
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _switchToNext();
    });
  }

  Future<void> _prepareInitialMedia() async {
    final currentItem = _items[_currentIndex];

    if (currentItem.type == 'video') {
      _currentController = VideoPlayerController.networkUrl(
        Uri.parse(currentItem.url),
      );
      await _currentController!.initialize();
      _currentController!.play();
    }

    await _preloadNext();
    setState(() {});
  }

  Future<void> _preloadNext() async {
    final nextIndex = (_currentIndex + 1) % _items.length;
    final nextItem = _items[nextIndex];

    if (nextItem.type == 'video') {
      _nextController = VideoPlayerController.networkUrl(
        Uri.parse(nextItem.url),
      );
      await _nextController!.initialize();
    } else {
      _nextController = null;
      await precacheImage(NetworkImage(nextItem.url), context);
    }
  }

  // Switching to the next media
  Future<void> _switchToNext() async {
    final nextIndex = (_currentIndex + 1) % _items.length;
    final nextItem = _items[nextIndex];
    final oldController = _currentController;

    setState(() {
      _currentIndex = nextIndex;
      _currentController = _nextController;
      _nextController = null;
    });

    if (nextItem.type == 'video' && _currentController == null) {
      _currentController = VideoPlayerController.networkUrl(
        Uri.parse(nextItem.url),
      );
      await _currentController!.initialize();
    }

    if (_currentController != null) {
      _currentController!.play();
    }

    oldController?.dispose();
    await _preloadNext();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    final currentItem = _items[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: currentItem.type == 'image'
            ? _buildImage(currentItem.url)
            : _buildVideo(),
      ),
    );
  }

  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true, // 🔥 prevents flicker
      errorBuilder: (_, __, ___) => const SizedBox(),
    );
  }

  Widget _buildVideo() {
    if (_currentController != null && _currentController!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _currentController!.value.size.width,
            height: _currentController!.value.size.height,
            child: VideoPlayer(_currentController!),
          ),
        ),
      );
    }

    return const SizedBox();
  }
}
