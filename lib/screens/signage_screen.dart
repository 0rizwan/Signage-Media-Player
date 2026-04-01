import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signage_media_player/models/media_item.dart';
import 'package:video_player/video_player.dart';

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
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          contentWidget,
        ],
      ),
    );
  }
}