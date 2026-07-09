import 'package:flutter/material.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/services/auth_service.dart';
import 'package:tikme/widgets/video_player_item.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late PocketBase _pb;
  late Future<List<RecordModel>> _videosFuture;
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pb = Provider.of<AuthService>(context, listen: false).pb;
    _videosFuture = _fetchVideos();
  }

  Future<List<RecordModel>> _fetchVideos() async {
    try {
      final records = await _pb
          .collection('posts')
          .getFullList(sort: '-created', expand: 'user');
      return records;
    } catch (e) {
      return [];
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _videosFuture = _fetchVideos();
    });
  }

  String _getFileUrl(RecordModel record, String filename) {
    if (filename.isEmpty) {
      return 'https://www.gravatar.com/avatar/?d=mp';
    }
    return _pb.files.getUrl(record, filename).toString();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<RecordModel>>(
          future: _videosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.novideofound),
              );
            } else {
              final videos = snapshot.data!;
              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: videos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final userRecords = video.get<List<RecordModel>>(
                    'expand.user',
                  );
                  final user = userRecords.isNotEmpty
                      ? userRecords.first
                      : null;

                  String username = AppLocalizations.of(
                    context,
                  )!.defaultUsername;
                  String profileImageUrl =
                      'https://www.gravatar.com/avatar/?d=mp';

                  if (user != null) {
                    username = user.getStringValue('username');
                    final avatarFilename = user.getStringValue('avatar');
                    if (avatarFilename.isNotEmpty) {
                      profileImageUrl = _getFileUrl(user, avatarFilename);
                    }
                  }

                  return VideoPlayerItem(
                    videoId: video.id,
                    videoUrl: _getFileUrl(video, video.data['video']),
                    username: username,
                    caption: video.data['caption'] ?? '',
                    profileImageUrl: profileImageUrl,
                    shouldPlay:
                        index ==
                        _currentPageIndex, // Only play current visible video
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
