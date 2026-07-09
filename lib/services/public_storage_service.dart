import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:media_scanner/media_scanner.dart';

class PublicStorageService {
  static Future<bool> requestStoragePermission() async {
    try {
      // For Android 10+, we need MANAGE_EXTERNAL_STORAGE for public directory access
      if (await _isAndroid10OrAbove()) {
        final status = await Permission.manageExternalStorage.request();
        if (status.isGranted) return true;
      }

      // Fallback to storage permission for older versions
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasStoragePermission() async {
    try {
      if (await _isAndroid10OrAbove()) {
        return await Permission.manageExternalStorage.status.isGranted;
      } else {
        return await Permission.storage.status.isGranted;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _isAndroid10OrAbove() async {
    try {
      if (Platform.isAndroid) {
        final versionString = Platform.version.split('.').first;
        final version = int.tryParse(versionString) ?? 0;
        return version >= 2; // Android 10 is API level 29
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<File?> downloadVideoToMoviesFolder({
    required String videoUrl,
    required String fileName,
    required String username,
    String caption = '',
  }) async {
    try {
      // Check permission first
      if (!await hasStoragePermission()) {
        final granted = await requestStoragePermission();
        if (!granted) {
          throw Exception(
            'Storage permission denied. Please grant permission to save videos to Movies folder.',
          );
        }
      }

      // Get the public Movies directory path
      final moviesDir = await _getPublicMoviesDirectory();
      if (!await moviesDir.exists()) {
        await moviesDir.create(recursive: true);
      }

      final safeFileName = _sanitizeFileName('$fileName.mp4');
      final file = File('${moviesDir.path}/$safeFileName');

      // Download the video
      final client = http.Client();
      final response = await client.get(Uri.parse(videoUrl));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        // Enhanced media store integration
        await _refreshMediaStore(file);

        // Optional: Add with metadata
        try {
          await addVideoToMediaStore(
            videoFile: file,
            title: fileName,
            description: caption.isNotEmpty ? caption : 'Video by $username',
            durationMs: 0,
          );
        } catch (e) {
          // Metadata addition failed silently
        }

        return file;
      } else {
        throw Exception('Failed to download video: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Directory> _getPublicMoviesDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Get the public external storage path
        final externalStorage = await _getExternalStoragePath();
        final moviesPath = '$externalStorage/Movies/Tikme';
        return Directory(moviesPath);
      } catch (e) {
        // Fallback to app-specific directory
        final appDir = await getApplicationDocumentsDirectory();
        final fallbackPath = '${appDir.path}/TikMe Downloads';
        return Directory(fallbackPath);
      }
    }

    // For iOS, use documents directory
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/TikMe Downloads');
  }

  static Future<String> _getExternalStoragePath() async {
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

  static Future<List<File>> getDownloadedVideos() async {
    try {
      final moviesDir = await _getPublicMoviesDirectory();

      if (!await moviesDir.exists()) {
        return [];
      }

      final files = await moviesDir.list().toList();
      final videoFiles = <File>[];

      for (var file in files) {
        if (file is File &&
            (file.path.endsWith('.mp4') || file.path.endsWith('.mov'))) {
          videoFiles.add(file);
        }
      }

      // Sort by modification time (newest first)
      videoFiles.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      return videoFiles;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> deleteDownloadedVideo(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        await _refreshMediaStore(file); // Remove from media store
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _refreshMediaStore(File file) async {
    if (Platform.isAndroid) {
      try {
        // Method 1: Use media_scanner package (recommended)
        await MediaScanner.loadMedia(path: file.path);

        // Note: The media_scanner package doesn't have scanFolder method
        // We'll scan individual files instead
      } catch (e) {
        // Method 2: Fallback to system command
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

  static Future<void> addVideoToMediaStore({
    required File videoFile,
    required String title,
    required String description,
    required int durationMs,
  }) async {
    if (Platform.isAndroid) {
      try {
        // Use media_scanner to ensure the file is properly indexed
        await MediaScanner.loadMedia(path: videoFile.path);
      } catch (e) {
        // Fallback to basic scanning
        await _refreshMediaStore(videoFile);
      }
    }
  }

  static Future<bool> isFileInMediaStore(File file) async {
    if (Platform.isAndroid) {
      try {
        // Check if file exists and is readable
        final exists = await file.exists();
        if (exists) {
          // Try to read file stats to verify accessibility
          final stat = await file.stat();
          return stat.size > 0;
        }
        return false;
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  static String _sanitizeFileName(String name) {
    // Remove invalid characters for file names
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  static String getPublicStoragePath() {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Movies/Tikme/';
    }
    return 'Movies/Tikme/';
  }

  // Method to check if we can access public storage
  static Future<bool> canAccessPublicStorage() async {
    try {
      final testDir = await _getPublicMoviesDirectory();
      final testFile = File('${testDir.path}/test_write.tmp');

      // Try to create and delete a test file
      await testFile.writeAsString('test');
      final exists = await testFile.exists();
      if (exists) {
        await testFile.delete();
      }

      return exists;
    } catch (e) {
      return false;
    }
  }

  // Method to get storage information
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final moviesDir = await _getPublicMoviesDirectory();
      final exists = await moviesDir.exists();
      final files = exists ? await getDownloadedVideos() : [];

      // Calculate total size using explicit integer addition
      int totalSize = 0;
      for (final file in files) {
        final fileSize = file.statSync().size;
        totalSize += fileSize as int;
        // Explicit integer addition
      }

      return {
        'path': moviesDir.path,
        'exists': exists,
        'fileCount': files.length,
        'totalSize': totalSize,
        'isPublic': moviesDir.path.contains('/storage/emulated/0/'),
      };
    } catch (e) {
      return {
        'path': 'Unknown',
        'exists': false,
        'fileCount': 0,
        'totalSize': 0,
        'isPublic': false,
      };
    }
  }
}
