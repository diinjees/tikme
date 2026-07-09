// ignore_for_file: prefer_final_fields, curly_braces_in_flow_control_structures, use_build_context_synchronously, unused_field

import 'package:flutter/material.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:media_scanner/media_scanner.dart';

class ExternalVideosScreen extends StatefulWidget {
  const ExternalVideosScreen({super.key});

  @override
  State<ExternalVideosScreen> createState() => _ExternalVideosScreenState();
}

class _ExternalVideosScreenState extends State<ExternalVideosScreen> {
  final TextEditingController _urlController = TextEditingController();
  List<Map<String, dynamic>> _externalVideos = [];
  bool _isDownloading = false;
  int _currentDownloadIndex = -1;

  // Supported platforms
  final List<String> _supportedPlatforms = [
    'youtube.com',
    'youtu.be',
    'tiktok.com',
    'vm.tiktok.com',
    'instagram.com',
    'facebook.com',
    'twitter.com',
    'x.com',
    'vimeo.com',
    'dailymotion.com',
  ];

  bool _isValidVideoUrl(String url) {
    return _supportedPlatforms.any((platform) => url.contains(platform));
  }

  String _getPlatformName(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be'))
      return 'YouTube';
    if (url.contains('tiktok.com')) return 'TikTok';
    if (url.contains('instagram.com')) return 'Instagram';
    if (url.contains('facebook.com')) return 'Facebook';
    if (url.contains('twitter.com') || url.contains('x.com')) return 'Twitter';
    if (url.contains('vimeo.com')) return 'Vimeo';
    if (url.contains('dailymotion.com')) return 'Dailymotion';
    return 'Unknown';
  }

  String _getVideoId(String url) {
    if (url.contains('youtube.com')) {
      final regExp = RegExp(r'v=([a-zA-Z0-9_-]+)');
      final match = regExp.firstMatch(url);
      return match?.group(1) ?? '';
    }
    if (url.contains('youtu.be')) {
      final regExp = RegExp(r'youtu.be/([a-zA-Z0-9_-]+)');
      final match = regExp.firstMatch(url);
      return match?.group(1) ?? '';
    }
    return url.split('/').last;
  }

  void _addExternalVideo() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    if (!_isValidVideoUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidVideoUrl),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _externalVideos.insert(0, {
        'url': url,
        'platform': _getPlatformName(url),
        'videoId': _getVideoId(url),
        'addedAt': DateTime.now().toIso8601String(),
        'status': 'pending', // pending, downloading, downloaded, error
        'progress': 0.0,
        'filePath': '',
      });
      _urlController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.videoAdded)),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await FlutterClipboard.paste();
    _urlController.text = data;
  }

  Future<void> _launchVideo(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotLaunchUrl),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadVideo(int index) async {
    if (_isDownloading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("downloadInProgress"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check storage permission
    if (!await _checkStoragePermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Storage permission required to download videos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _currentDownloadIndex = index;
      _externalVideos[index]['status'] = 'downloading';
      _externalVideos[index]['progress'] = 0.0;
    });

    try {
      final video = _externalVideos[index];
      final url = video['url'] as String;
      final platform = video['platform'] as String;
      final videoId = video['videoId'] as String;

      // Get Movies/Tikme directory
      final directory = await _getMoviesTikmeDirectory();
      final fileName = _sanitizeFileName(
        '${platform}_$videoId${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      final file = File('${directory.path}/$fileName');

      // Download the video
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        int bytesDownloaded = 0;
        final List<int> bytes = [];

        await for (var chunk in response.stream) {
          bytes.addAll(chunk);
          bytesDownloaded += chunk.length;

          if (contentLength > 0) {
            final progress = bytesDownloaded / contentLength;
            setState(() {
              _externalVideos[index]['progress'] = progress;
            });
          }
        }

        await file.writeAsBytes(bytes);

        // Refresh media store to make video visible in gallery
        await _refreshMediaStore(file);

        setState(() {
          _externalVideos[index]['status'] = 'downloaded';
          _externalVideos[index]['progress'] = 1.0;
          _externalVideos[index]['filePath'] = file.path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video downloaded to Movies/Tikme folder'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to download video: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _externalVideos[index]['status'] = 'error';
        _externalVideos[index]['progress'] = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
        _currentDownloadIndex = -1;
      });
    }
  }

  Future<bool> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      // Check for Android 10+ (API 29+)
      if (await _isAndroid10OrAbove()) {
        final status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          final result = await Permission.manageExternalStorage.request();
          return result.isGranted;
        }
        return true;
      } else {
        // For older Android versions
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          final result = await Permission.storage.request();
          return result.isGranted;
        }
        return true;
      }
    }
    return true; // For iOS, handle permissions accordingly
  }

  Future<bool> _isAndroid10OrAbove() async {
    try {
      if (Platform.isAndroid) {
        final versionString = Platform.version.split('.').first;
        final version = int.tryParse(versionString) ?? 0;
        print("vesrsiom : $versionString");
        return version >= 2; // Android 10 is API level 29
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Directory> _getMoviesTikmeDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Get the public external storage path
        final externalStorage = await _getExternalStoragePath();
        final moviesPath = '$externalStorage/Movies/Tikme';
        final directory = Directory(moviesPath);

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        return directory;
      } catch (e) {
        // Fallback to app-specific directory
        final appDir = await getApplicationDocumentsDirectory();
        final fallbackPath = '${appDir.path}/TikMe Downloads';
        final directory = Directory(fallbackPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        return directory;
      }
    } else {
      // For iOS, use documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/TikMe Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    }
  }

  Future<String> _getExternalStoragePath() async {
    if (Platform.isAndroid) {
      // Common external storage paths for Android
      final List<String> possiblePaths = [
        '/storage/emulated/0',
        '/storage/sdcard0',
        '/sdcard',
        '/storage/self/primary',
      ];

      for (String path in possiblePaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          return path;
        }
      }

      // Fallback: try to get from external storage directory
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Extract the base path (remove the Android/data/... part)
        final path = externalDir.path;
        if (path.contains('/Android/data/')) {
          final basePath = path.split('/Android/data/').first;
          return basePath;
        }
        return path;
      }
    }

    throw Exception('Could not find external storage path');
  }

  Future<void> _refreshMediaStore(File file) async {
    if (Platform.isAndroid) {
      try {
        // Use media_scanner package to make video visible in gallery
        await MediaScanner.loadMedia(path: file.path);
      } catch (e) {
        // Fallback to system command
        try {
          await Process.run('am', [
            'broadcast',
            '-a',
            'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
            '-d',
            'file://${file.path}',
          ]);
        } catch (e) {
          // Both methods failed, continue silently
        }
      }
    }
  }

  String _sanitizeFileName(String name) {
    // Remove invalid characters for file names
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  void _deleteVideo(int index) {
    setState(() {
      _externalVideos.removeAt(index);
    });
  }

  void _openDownloadedVideo(String filePath) {
    // You can implement video player here or show file location
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Video saved to: $filePath'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return Icon(Icons.play_circle_filled, color: Colors.red);
      case 'tiktok':
        return Icon(Icons.music_note, color: Colors.black);
      case 'instagram':
        return Icon(Icons.camera_alt, color: Colors.purple);
      case 'facebook':
        return Icon(Icons.facebook, color: Colors.blue);
      case 'twitter':
        return Icon(Icons.chat, color: Colors.blue);
      case 'vimeo':
        return Icon(Icons.videocam, color: Colors.blue);
      case 'dailymotion':
        return Icon(Icons.play_arrow, color: Colors.blue);
      default:
        return Icon(Icons.video_library, color: Colors.grey);
    }
  }

  Widget _getStatusIcon(String status, double progress) {
    switch (status) {
      case 'pending':
        return Icon(Icons.download, color: Colors.blue);
      case 'downloading':
        return Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(value: progress, strokeWidth: 2),
            Icon(Icons.downloading, size: 20, color: Colors.blue),
          ],
        );
      case 'downloaded':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'error':
        return Icon(Icons.error, color: Colors.red);
      default:
        return Icon(Icons.download, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.externalVideos),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.supportedPlatforms),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _supportedPlatforms.map((platform) {
                      return Text('• ${_getPlatformName(platform)}');
                    }).toList(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.close),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Add URL Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.pasteVideoUrl,
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.paste),
                        onPressed: _pasteFromClipboard,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addExternalVideo,
                  child: Text(AppLocalizations.of(context)!.add),
                ),
              ],
            ),
          ),
          Divider(),
          // Videos List
          Expanded(
            child: _externalVideos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.noExternalVideos,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.addVideoUrlsHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _externalVideos.length,
                    itemBuilder: (context, index) {
                      final video = _externalVideos[index];
                      final status = video['status'] as String;
                      final progress = video['progress'] as double;

                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: _getPlatformIcon(video['platform']!),
                          title: Text(video['platform']!),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video['url']!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              if (status == 'downloading')
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              if (status == 'downloaded')
                                Text(
                                  'Saved to Movies/Tikme',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: _getStatusIcon(status, progress),
                                onPressed: () {
                                  if (status == 'pending') {
                                    _downloadVideo(index);
                                  } else if (status == 'downloaded') {
                                    _openDownloadedVideo(video['filePath']!);
                                  } else if (status == 'error') {
                                    _downloadVideo(index); // Retry
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteVideo(index),
                              ),
                            ],
                          ),
                          onTap: () => _launchVideo(video['url']!),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
