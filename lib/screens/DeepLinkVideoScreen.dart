import 'package:flutter/material.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/widgets/video_player_item.dart';
import 'package:tikme/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:pocketbase/pocketbase.dart';

class DeepLinkVideoScreen extends StatefulWidget {
  final String videoId;

  const DeepLinkVideoScreen({super.key, required this.videoId});

  @override
  State<DeepLinkVideoScreen> createState() => _DeepLinkVideoScreenState();
}

class _DeepLinkVideoScreenState extends State<DeepLinkVideoScreen> {
  late final PocketBase _pb;
  bool _isLoading = true;
  bool _error = false;
  Map<String, dynamic>? _videoData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pb = Provider.of<AuthService>(context, listen: false).pb;
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      final video = await _pb.collection('posts').getOne(widget.videoId);
      setState(() {
        _videoData = {
          'id': video.id,
          'videoUrl': _getFileUrl(video, video.data['video'] as String),
          'username': video.data['username'] as String? ?? 'Unknown',
          'caption': video.data['caption'] as String? ?? '',
          'profileImageUrl': _getUserAvatar(video),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _isLoading = false;
      });
    }
  }

  String _getFileUrl(RecordModel record, String filename) {
    return _pb.files.getUrl(record, filename).toString();
  }

  String _getUserAvatar(RecordModel video) {
    try {
      final avatar = video.data['user_avatar'] as String?;
      if (avatar != null && avatar.isNotEmpty) {
        return _getFileUrl(video, avatar);
      }
    } catch (e) {
      // Fall through to default avatar
    }
    return 'https://via.placeholder.com/150'; // Default avatar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.video),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.novideofound,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.viewingVideoWithId(widget.videoId),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadVideo,
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            )
          : _videoData == null
          ? Center(child: Text(AppLocalizations.of(context)!.videonotavailable))
          : VideoPlayerItem(
              videoId: _videoData!['id'],
              videoUrl: _videoData!['videoUrl'],
              username: _videoData!['username'],
              caption: _videoData!['caption'],
              profileImageUrl: _videoData!['profileImageUrl'],
            ),
    );
  }
}
