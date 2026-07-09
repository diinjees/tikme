// ignore_for_file: deprecated_member_use, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:tikme/screens/comment_screen.dart';
import 'package:tikme/screens/profile_screen.dart';
import 'package:tikme/screens/downloads_screen.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tikme/services/auth_service.dart';
import 'package:tikme/services/public_storage_service.dart';

class ActionsToolbar extends StatefulWidget {
  final String username;
  final String profileImageUrl;
  final String videoId;
  final String videoUrl;
  final String caption;

  const ActionsToolbar({
    super.key,
    required this.profileImageUrl,
    required this.username,
    required this.videoId,
    required this.videoUrl,
    required this.caption,
  });

  @override
  State<ActionsToolbar> createState() => _ActionsToolbarState();
}

class _ActionsToolbarState extends State<ActionsToolbar> {
  late final PocketBase _pb;
  bool _isLiked = false;
  int _likesCount = 0;
  int _commentsCount = 0;
  bool _isFollowing = false;
  RecordModel? _profileUser;
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _pb = Provider.of<AuthService>(context, listen: false).pb;
    _checkIfLiked();
    _initializeProfile();
    _getStats();
  }

  Future<void> _initializeProfile() async {
    try {
      final userRecord = await _pb
          .collection('users')
          .getFirstListItem('username="${widget.username}"');
      _profileUser = userRecord;

      if (mounted) {
        setState(() {
          _checkIffollowing();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _getStats() async {
    try {
      final post = await _pb.collection('posts').getOne(widget.videoId);
      final comments = await _pb
          .collection('comments')
          .getFullList(filter: 'post="${widget.videoId}"');

      if (mounted) {
        setState(() {
          _likesCount = post.getListValue<String>('likes').length;
          _commentsCount = comments.length;
        });
      }
    } catch (e) {
      // Error handled silently
    }
  }

  Future<void> _checkIfLiked() async {
    final currentUser = _pb.authStore.record;
    if (currentUser == null) return;

    try {
      final post = await _pb.collection('posts').getOne(widget.videoId);
      final likedBy = post.getListValue<String>('likes');

      if (mounted) {
        setState(() {
          _isLiked = likedBy.contains(currentUser.id);
        });
      }
    } catch (e) {
      // Error handled silently
    }
  }

  Future<void> _checkIffollowing() async {
    if (_profileUser == null) return;
    final currentUser = _pb.authStore.record;
    if (currentUser == null || currentUser.id == _profileUser!.id) return;

    try {
      final user = await _pb
          .collection('users')
          .getOne(currentUser.id, expand: 'following');
      final followingList = user
          .getListValue<RecordModel>('expand.following')
          .map((e) => e.id)
          .toList();

      if (mounted) {
        setState(() {
          _isFollowing = followingList.contains(_profileUser!.id);
        });
      }
    } catch (e) {
      // Error handled silently
    }
  }

  Future<void> _toggleLike() async {
    final currentUser = _pb.authStore.record;
    if (currentUser == null) {
      _showSnackbar('Please login to like videos');
      return;
    }

    try {
      final post = await _pb.collection('posts').getOne(widget.videoId);
      final likedBy = List<String>.from(post.getListValue<String>('likes'));

      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked) {
          _likesCount++;
          if (!likedBy.contains(currentUser.id)) {
            likedBy.add(currentUser.id);
          }
        } else {
          _likesCount--;
          likedBy.remove(currentUser.id);
        }
      });

      await _pb
          .collection('posts')
          .update(widget.videoId, body: {'likes': likedBy});
    } catch (e) {
      // Revert UI on error
      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked) {
          _likesCount++;
        } else {
          _likesCount--;
        }
      });
      _showErrorSnackbar('Failed to update like');
    }
  }

  Future<void> _toggleFollow() async {
    final currentUser = _pb.authStore.record;
    if (currentUser == null) {
      _showSnackbar('Please login to follow users');
      return;
    }

    if (_profileUser == null || currentUser.id == _profileUser!.id) return;

    try {
      final user = await _pb
          .collection('users')
          .getOne(currentUser.id, expand: 'following');

      final followingList = List<String>.from(
        user.getListValue<String>('following'),
      );

      setState(() {
        _isFollowing = !_isFollowing;
        if (_isFollowing) {
          if (!followingList.contains(_profileUser!.id)) {
            followingList.add(_profileUser!.id);
          }
        } else {
          followingList.remove(_profileUser!.id);
        }
      });

      await _pb
          .collection('users')
          .update(currentUser.id, body: {'following': followingList});
    } catch (e) {
      // Revert UI on error
      setState(() {
        _isFollowing = !_isFollowing;
      });
      _showErrorSnackbar('Failed to update follow');
    }
  }

  Future<void> _downloadVideo() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      _showSnackbar('Downloading video to Movies/Tikme folder...');

      final file = await PublicStorageService.downloadVideoToMoviesFolder(
        videoUrl: widget.videoUrl,
        fileName: '${widget.username}_${DateTime.now().millisecondsSinceEpoch}',
        username: widget.username,
        caption: widget.caption,
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
        });

        // Check if file is visible in gallery
        final isInGallery = await PublicStorageService.isFileInMediaStore(
          file!,
        );

        _showSuccessSnackbar(
          isInGallery
              ? 'Video saved to Movies/Tikme folder and gallery!'
              : 'Video saved to Movies/Tikme folder!',
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DownloadsScreen()),
              );
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });

        String errorMessage = 'Download failed';
        if (e.toString().contains('permission denied')) {
          errorMessage =
              'Storage permission required. Please grant "All files access" permission in app settings.';
        } else if (e.toString().contains('Failed to download video')) {
          errorMessage = 'Network error. Please check your connection.';
        } else {
          errorMessage = 'Download failed: ${e.toString()}';
        }

        _showErrorSnackbar(errorMessage);
      }
    }
  }

  void _shareVideo() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final String videoShareUrl = 'tikme://video/${widget.videoId}';
      final String shareText = widget.caption.isNotEmpty
          ? 'Check out this video by ${widget.username}: "${widget.caption}" $videoShareUrl'
          : 'Check out this awesome video by ${widget.username}! $videoShareUrl';

      await Share.share(shareText, subject: 'Video by ${widget.username}');
    } catch (e) {
      _showErrorSnackbar('Failed to share');
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Download Video',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Video by: ${widget.username}'),
            if (widget.caption.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Caption: "${widget.caption}"',
                style: const TextStyle(fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: PublicStorageService.getStorageInfo(),
              builder: (context, snapshot) {
                final storageInfo = snapshot.data ?? {};
                final isPublic = storageInfo['isPublic'] == true;
                final path = storageInfo['path'] ?? 'Unknown';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This will download the video to:',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      path,
                      style: TextStyle(
                        color: isPublic ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPublic
                          ? 'Videos will be visible in your gallery app.'
                          : 'Videos are saved to app storage.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadVideo();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: _isDownloading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _showSuccessSnackbar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        action: action,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Widget _buildProfileAction() {
    final currentUser = _pb.authStore.record;
    final isCurrentUser =
        currentUser != null &&
        _profileUser != null &&
        currentUser.id == _profileUser!.id;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              username: widget.username,
              profileImageUrl: widget.profileImageUrl,
            ),
          ),
        );
      },
      onLongPress: isCurrentUser ? null : _toggleFollow,
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(bottom: 10),
        child: Stack(
          children: <Widget>[
            // Profile Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isFollowing ? Colors.red : Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: widget.profileImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.profileImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.person, color: Colors.grey[600]),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.person, color: Colors.grey[600]),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
              ),
            ),
            // Follow indicator
            if (!isCurrentUser && !_isFollowing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 10),
                ),
              ),
            // Following indicator
            if (!isCurrentUser && _isFollowing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeAction() {
    return _SocialAction(
      icon: _isLiked ? Icons.favorite : Icons.favorite_border,
      count: _likesCount,
      onPressed: _toggleLike,
      color: _isLiked ? Colors.red : Colors.white,
      tooltip: 'Like',
    );
  }

  Widget _buildCommentAction() {
    return _SocialAction(
      icon: Icons.comment,
      count: _commentsCount,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CommentScreen(postId: widget.videoId),
          ),
        );
      },
      tooltip: 'Comments',
    );
  }

  Widget _buildDownloadAction() {
    return _SocialAction(
      icon: _isDownloading ? Icons.downloading : Icons.download,
      count: null,
      onPressed: _isDownloading ? null : _showDownloadDialog,
      color: _isDownloading ? Colors.grey : Colors.white,
      tooltip: _isDownloading ? 'Downloading...' : 'Download',
    );
  }

  Widget _buildShareAction() {
    return _SocialAction(
      icon: _isSharing ? Icons.share : Icons.share,
      count: null,
      onPressed: _isSharing ? null : _shareVideo,
      color: _isSharing ? Colors.grey : Colors.white,
      tooltip: _isSharing ? 'Sharing...' : 'Share',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildProfileAction(),
            const SizedBox(height: 8),
            _buildLikeAction(),
            const SizedBox(height: 8),
            _buildCommentAction(),
            const SizedBox(height: 8),
            _buildDownloadAction(),
            const SizedBox(height: 8),
            _buildShareAction(),
            //const SizedBox(height: 8),
            //_buildExternalVideosAction(),
          ],
        ),
      ),
    );
  }
}

class _SocialAction extends StatelessWidget {
  final IconData icon;
  final int? count;
  final VoidCallback? onPressed;
  final Color color;
  final String tooltip;

  const _SocialAction({
    required this.icon,
    this.count,
    required this.onPressed,
    this.color = Colors.white,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 48,
          height: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 28, color: color),
              if (count != null) ...[
                const SizedBox(height: 2),
                Text(
                  _formatCount(count!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}
