import 'package:flutter/material.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/screens/external_videos_screen.dart';
import 'package:tikme/services/public_storage_service.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class DownloadedVideo {
  final String name;
  final String filePath;
  final int size;
  final DateTime downloadDate;

  DownloadedVideo({
    required this.name,
    required this.filePath,
    required this.size,
    required this.downloadDate,
  });
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<DownloadedVideo> downloadedVideos = [];
  bool _isLoading = true;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadVideos();
  }

  Future<void> _requestPermissionAndLoadVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final granted = await PublicStorageService.requestStoragePermission();

      setState(() {
        _permissionGranted = granted;
      });

      if (granted) {
        await _loadDownloadedVideos();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Error requesting permission: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loadDownloadedVideos() async {
    try {
      final files = await PublicStorageService.getDownloadedVideos();
      final videos = <DownloadedVideo>[];

      for (var file in files) {
        try {
          final stat = await file.stat();
          final fileName = file.uri.pathSegments.last.replaceAll('.mp4', '');

          videos.add(
            DownloadedVideo(
              name: fileName,
              filePath: file.path,
              size: stat.size,
              downloadDate: stat.modified,
            ),
          );
        } catch (e) {}
      }

      // Sort by download date (newest first)
      videos.sort((a, b) => b.downloadDate.compareTo(a.downloadDate));

      setState(() {
        downloadedVideos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Error loading downloads: $e');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 1) return 'Just now';
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return AppLocalizations.of(context)!.yesterday;
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _deleteDownload(int index) async {
    final video = downloadedVideos[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletevideo),
        content: Text(AppLocalizations.of(context)!.deletesure(video.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete(index, video);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.deletebutton),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(int index, DownloadedVideo video) async {
    try {
      final file = File(video.filePath);
      final success = await PublicStorageService.deleteDownloadedVideo(file);

      if (success) {
        setState(() {
          downloadedVideos.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.deletesuccessfully(video.name),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {}
    } catch (e) {
      _showErrorSnackbar('Failed to delete: ${e.toString()}');
    }
  }

  void _playDownloadedVideo(DownloadedVideo video) async {
    try {
      final file = File(video.filePath);
      if (await file.exists()) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DownloadedVideoPlayerScreen(
              videoPath: video.filePath,
              videoName: video.name,
            ),
          ),
        );
      } else {
        _showErrorSnackbar(AppLocalizations.of(context)!.novideofound);
        // Refresh list to remove missing files
        _loadDownloadedVideos();
      }
    } catch (e) {
      _showErrorSnackbar('Cannot play video: ${e.toString()}');
    }
  }

  void _deleteAllDownloads() {
    if (downloadedVideos.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletealldownload),
        content: Text(
          AppLocalizations.of(
            context,
          )!.deletealldownloadsure(downloadedVideos.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDeleteAll();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.deleteall),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAll() async {
    setState(() {
      _isLoading = true;
    });

    try {
      int successCount = 0;
      int failCount = 0;

      for (var video in downloadedVideos) {
        try {
          final file = File(video.filePath);
          final success = await PublicStorageService.deleteDownloadedVideo(
            file,
          );
          if (success) {
            successCount++;
          } else {
            failCount++;
          }
        } catch (e) {
          failCount++;
          print('Error deleting ${video.name}: $e');
        }
      }

      setState(() {
        downloadedVideos.clear();
        _isLoading = false;
      });

      String message = '$successCount videos deleted successfully';
      if (failCount > 0) {
        message += ', $failCount failed to delete';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Error deleting all videos: ${e.toString()}');
    }
  }

  void _openFileLocation(DownloadedVideo video) async {
    try {
      final file = File(video.filePath);
      final directory = file.parent;

      if (await directory.exists()) {
        // This would typically open the file manager at that location
        // For now, show a dialog with the path
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.filelocation),
            content: SelectableText(
              directory.path,
              style: TextStyle(fontFamily: 'monospace'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.close),
              ),
            ],
          ),
        );
      } else {
        _showErrorSnackbar('Directory not found');
      }
    } catch (e) {
      _showErrorSnackbar('Cannot open file location: ${e.toString()}');
    }
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off_rounded, size: 80, color: Colors.orange),
            SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.storagereq,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.storagereqsure,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _requestPermissionAndLoadVideos,
              icon: Icon(Icons.lock_open),
              label: Text(AppLocalizations.of(context)!.grantpermission),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => openAppSettings(),
              icon: Icon(Icons.settings),
              label: Text(AppLocalizations.of(context)!.opensettings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDownloadsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_for_offline_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noDownloads,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.downloadtitel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadDownloadedVideos,
              icon: Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadsListView() {
    final totalSize = downloadedVideos.fold(
      0,
      (sum, video) => sum + video.size,
    );

    return Column(
      children: [
        // Header with stats
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${downloadedVideos.length} video${downloadedVideos.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    _formatFileSize(totalSize),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.folder, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Movies/TikMe',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Videos list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDownloadedVideos,
            child: ListView.builder(
              itemCount: downloadedVideos.length,
              itemBuilder: (context, index) {
                final video = downloadedVideos[index];
                return _buildVideoItem(video, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoItem(DownloadedVideo video, int index) {
    return Dismissible(
      key: Key('${video.filePath}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deletevideo),
            content: Text('Are you sure you want to delete "${video.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancelButton),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(AppLocalizations.of(context)!.deletebutton),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _performDelete(index, video);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 1,
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.videocam, color: Colors.blue, size: 24),
          ),
          title: Text(
            video.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _formatFileSize(video.size),
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _formatDate(video.downloadDate),
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'play':
                  _playDownloadedVideo(video);
                  break;
                case 'location':
                  _openFileLocation(video);
                  break;
                case 'delete':
                  _deleteDownload(index);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'play',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, size: 20),
                    SizedBox(width: 8),
                    Text("play"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'location',
                child: Row(
                  children: [
                    Icon(Icons.folder_open, size: 20),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.location),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.deletebutton,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _playDownloadedVideo(video),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.downloads),
        actions: [
          if (_permissionGranted) ...[
            IconButton(
              icon: Icon(Icons.link),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ExternalVideosScreen(),
                  ),
                );
              },
              tooltip: AppLocalizations.of(context)!.linkdownload,
            ),
            if (downloadedVideos.isNotEmpty)
              IconButton(
                icon: Icon(Icons.delete_sweep),
                onPressed: _deleteAllDownloads,
                tooltip: AppLocalizations.of(context)!.deleteall,
              ),
          ],
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.loadingdownload,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : !_permissionGranted
          ? _buildPermissionDeniedView()
          : downloadedVideos.isEmpty
          ? _buildEmptyDownloadsView()
          : _buildDownloadsListView(),
      floatingActionButton: _permissionGranted && downloadedVideos.isNotEmpty
          ? FloatingActionButton(
              onPressed: _loadDownloadedVideos,
              tooltip: AppLocalizations.of(context)!.refresh,
              child: Icon(Icons.refresh),
            )
          : null,
    );
  }
}

class DownloadedVideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String videoName;

  const DownloadedVideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.videoName,
  });

  @override
  State<DownloadedVideoPlayerScreen> createState() =>
      _DownloadedVideoPlayerScreenState();
}

class _DownloadedVideoPlayerScreenState
    extends State<DownloadedVideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _isBuffering = true;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _isBuffering = false;
              });
              _controller.play();
              _controller.setLooping(true);
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                _isBuffering = false;
              });
            }
            print('Video player error: $error');
          });

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
      _showControls = true;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  void _seekRelative(Duration duration) {
    final newPosition = _controller.value.position + duration;
    if (newPosition < Duration.zero) {
      _controller.seekTo(Duration.zero);
    } else if (newPosition > _controller.value.duration) {
      _controller.seekTo(_controller.value.duration);
    } else {
      _controller.seekTo(newPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showControls
          ? AppBar(
              title: Text(widget.videoName, overflow: TextOverflow.ellipsis),
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppLocalizations.of(context)!.close,
                ),
              ],
            )
          : null,
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video Player
            Center(
              child: _isBuffering
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.loadingvideo,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  : _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.videofailed,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.videonotwork,
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(AppLocalizations.of(context)!.goback),
                        ),
                      ],
                    ),
            ),

            // Play/Pause overlay
            if (!_isPlaying && _showControls)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Controls overlay
            if (_showControls && _controller.value.isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black54,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Progress bar
                      Row(
                        children: [
                          Text(
                            _formatDuration(_controller.value.position),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Expanded(
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: Colors.red,
                                bufferedColor: Colors.grey[600]!,
                                backgroundColor: Colors.grey[800]!,
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.replay_10, size: 28),
                            color: Colors.white,
                            onPressed: () =>
                                _seekRelative(Duration(seconds: -10)),
                            tooltip: 'Rewind 10s',
                          ),
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 36,
                            ),
                            color: Colors.white,
                            onPressed: _togglePlayPause,
                            tooltip: _isPlaying ? 'Pause' : 'Play',
                          ),
                          IconButton(
                            icon: Icon(Icons.forward_10, size: 28),
                            color: Colors.white,
                            onPressed: () =>
                                _seekRelative(Duration(seconds: 10)),
                            tooltip: 'Forward 10s',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
