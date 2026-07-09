import 'package:flutter/material.dart';

class VideoInfo extends StatelessWidget {
  final String username;
  final String caption;

  const VideoInfo({super.key, required this.username, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(caption, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
