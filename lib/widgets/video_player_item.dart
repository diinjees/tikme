import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:tikme/widgets/video_info.dart';
import 'package:tikme/widgets/actions_toolbar.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoId;
  final String videoUrl;
  final String username;
  final String caption;
  final String profileImageUrl;
  final bool shouldPlay;

  const VideoPlayerItem({
    super.key,
    required this.videoId,
    required this.videoUrl,
    required this.username,
    required this.caption,
    required this.profileImageUrl,
    this.shouldPlay = false,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  late AnimationController _iconAnimationController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          // Only play if shouldPlay is true
          _playVideo();
        }
      });

    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _iconAnimationController.value = 1.0; // Show icon initially
  }

  @override
  void didUpdateWidget(VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle play/pause based on visibility changes
    if (widget.shouldPlay != oldWidget.shouldPlay) {
      if (widget.shouldPlay) {
        _playVideo();
      } else {
        _pauseVideo();
      }
    }
  }

  void _playVideo() {
    if (_isInitialized && !_isPlaying) {
      _controller.play();
      _controller.setLooping(true);
      setState(() {
        _isPlaying = true;
      });
      _iconAnimationController.reverse(); // Fade out icon
    }
  }

  void _pauseVideo() {
    if (_isInitialized && _isPlaying) {
      _controller.pause();
      setState(() {
        _isPlaying = false;
      });
      _iconAnimationController.forward(from: 0.0); // Fade in icon
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pauseVideo();
    } else {
      _playVideo();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: _togglePlayPause,
          child: SizedBox.expand(
            child: _isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: Center(child: CircularProgressIndicator()),
                  ),
          ),
        ),
        // Show play icon when video is not playing
        if (!_isPlaying && _isInitialized)
          Center(
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(_iconAnimationController),
              child: Icon(Icons.play_arrow, size: 60.0, color: Colors.white),
            ),
          ),
        VideoInfo(username: widget.username, caption: widget.caption),
        ActionsToolbar(
          username: widget.username,
          profileImageUrl: widget.profileImageUrl,
          videoId: widget.videoId,
          videoUrl: widget.videoUrl,
          caption: widget.caption,
        ),
      ],
    );
  }
}
