// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/screens/conversation_screen.dart';
import 'package:tikme/screens/downloads_screen.dart';
import 'package:tikme/screens/followers_screen.dart';
import 'package:tikme/screens/following_screen.dart';
import 'package:tikme/screens/settings_screen.dart';
import 'package:tikme/services/auth_service.dart';
import 'package:tikme/widgets/video_player_item.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final String username;
  final String profileImageUrl;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.profileImageUrl,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final PocketBase _pb;
  bool _isInitialized = false;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  RecordModel? _profileUser;

  late Future<List<RecordModel>> _uploadedVideosFuture;
  late Future<List<RecordModel>>
  _likedVideosFuture; // New future for liked videos
  late Future<int> _followersCountFuture;
  late Future<int> _followingCountFuture;
  bool _isFollowing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _pb = Provider.of<AuthService>(context).pb;
      _initializeProfile();
      _isInitialized = true;
      _navigateToDownloads();
    }
  }

  Future<void> _initializeProfile() async {
    try {
      final userRecord = await _pb
          .collection('users')
          .getFirstListItem('username="${widget.username}"');
      _profileUser = userRecord;

      if (mounted) {
        setState(() {
          _uploadedVideosFuture = _fetchUploadedVideos();
          _likedVideosFuture =
              _fetchLikedVideos(); // Initialize liked videos future
          _followersCountFuture = _fetchFollowersCount();
          _followingCountFuture = _fetchFollowingCount();
          _checkIfFollowing();
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error initializing profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _checkNetworkAvailability() async {
    try {
      // Check both connectivity and actual internet access
      final connectivityResult = await Connectivity().checkConnectivity();

      // If no network interfaces are active, definitely no internet
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Even if interfaces are active, verify real internet access
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      // Any error means no internet
      return false;
    }
  }

  void _navigateToDownloads() async {
    final appLocalizations = AppLocalizations.of(context)!;

    // Check network availability
    if (!await _checkNetworkAvailability()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.noInternetConnection),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const DownloadsScreen()));
    }

    return;
  }

  Future<void> _pickImage(ImageSource source) async {
    final appLocalizations = AppLocalizations.of(context)!;
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        await _uploadProfilePicture(File(pickedFile.path));
      }
    } catch (e) {
      log('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.errorPickingImage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    final appLocalizations = AppLocalizations.of(context)!;
    if (_profileUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final multipartFile = await http.MultipartFile.fromPath(
        'avatar',
        imageFile.path,
      );

      final updatedRecord = await _pb
          .collection('users')
          .update(_profileUser!.id, files: [multipartFile]);

      setState(() {
        _profileUser = updatedRecord;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.profilePictureUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      log('Error uploading profile picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appLocalizations.failedToUploadProfilePicture(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImagePickerOptions() {
    final appLocalizations = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(appLocalizations.photoLibrary),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(appLocalizations.camera),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<RecordModel>> _fetchUploadedVideos() async {
    if (_profileUser == null) return [];
    try {
      final records = await _pb
          .collection('posts')
          .getFullList(
            sort: '-created',
            filter: 'user = "${_profileUser!.id}"',
            expand: 'user',
          );
      return records;
    } catch (e) {
      log('Error fetching uploaded videos: $e');
      return [];
    }
  }

  Future<List<RecordModel>> _fetchLikedVideos() async {
    // New method to fetch liked videos
    if (_profileUser == null) return [];
    try {
      final records = await _pb
          .collection('posts')
          .getFullList(
            sort: '-created',
            filter:
                'likes ~ "${_profileUser!.id}"', // Filter for posts where likes array contains user ID
            expand: 'user',
          );
      return records;
    } catch (e) {
      log('Error fetching liked videos: $e');
      return [];
    }
  }

  Future<int> _fetchFollowersCount() async {
    if (_profileUser == null) return 0;
    try {
      final user = await _pb
          .collection('users')
          .getOne(_profileUser!.id, expand: 'followers');
      // Correctly extract from a list if 'expand.followers' is a list of RecordModels
      final dynamic expandedFollowers = user.data['expand']?['followers'];
      if (expandedFollowers is List) {
        return expandedFollowers.length;
      }
      return 0;
    } catch (e) {
      log('Error fetching followers count: $e');
      return 0;
    }
  }

  Future<int> _fetchFollowingCount() async {
    if (_profileUser == null) return 0;
    try {
      final user = await _pb
          .collection('users')
          .getOne(_profileUser!.id, expand: 'following');
      // Correctly extract from a list if 'expand.following' is a list of RecordModels
      final dynamic expandedFollowing = user.data['expand']?['following'];
      if (expandedFollowing is List) {
        return expandedFollowing.length;
      }
      return 0;
    } catch (e) {
      log('Error fetching following count: $e');
      return 0;
    }
  }

  Future<void> _checkIfFollowing() async {
    if (_profileUser == null) return;
    final currentUser = _pb.authStore.record;
    if (currentUser == null || currentUser.id == _profileUser!.id) return;

    try {
      final user = await _pb
          .collection('users')
          .getOne(currentUser.id, expand: 'following');
      final followingList = user
          .getListValue<String>(
            'following',
          ) // This gets the raw IDs, not expanded records
          .toList();
      if (mounted) {
        setState(() {
          _isFollowing = followingList.contains(_profileUser!.id);
        });
      }
    } catch (e) {
      log('Error checking if following: $e');
    }
  }

  Future<void> _toggleFollow() async {
    final appLocalizations = AppLocalizations.of(context)!;
    if (_profileUser == null) return;
    final currentUser = _pb.authStore.record;
    if (currentUser == null || currentUser.id == _profileUser!.id) return;

    final isCurrentlyFollowing = _isFollowing;

    // Optimistic UI update
    setState(() {
      _isFollowing = !isCurrentlyFollowing;
    });

    try {
      // Update current user's following list
      final currentUserRecord = await _pb
          .collection('users')
          .getOne(currentUser.id);
      final currentUserFollowing = currentUserRecord.getListValue<String>(
        'following',
      );

      if (isCurrentlyFollowing) {
        currentUserFollowing.remove(_profileUser!.id);
      } else {
        currentUserFollowing.add(_profileUser!.id);
      }
      await _pb
          .collection('users')
          .update(currentUser.id, body: {'following': currentUserFollowing});

      // Update profile user's followers list
      final profileUserRecord = await _pb
          .collection('users')
          .getOne(_profileUser!.id);
      final profileUserFollowers = profileUserRecord.getListValue<String>(
        'followers',
      );

      if (isCurrentlyFollowing) {
        profileUserFollowers.remove(currentUser.id);
      } else {
        profileUserFollowers.add(currentUser.id);
      }
      await _pb
          .collection('users')
          .update(_profileUser!.id, body: {'followers': profileUserFollowers});

      if (mounted) {
        setState(() {
          _followersCountFuture = _fetchFollowersCount();
          _followingCountFuture = _fetchFollowingCount();
        });
      }
    } catch (e) {
      // Revert UI on error
      setState(() {
        _isFollowing = isCurrentlyFollowing;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.failedToToggleFollow(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getSafeString(dynamic value, [String fallback = '']) {
    return value is String ? value : fallback;
  }

  String? _getSafeStringOrNull(dynamic value) {
    return value is String ? value : null;
  }

  // New method to safely get user data from expanded relation
  String _getUsernameFromVideo(RecordModel video) {
    try {
      final expandedUser = video.expand['user'];
      if (expandedUser is List && expandedUser!.isNotEmpty) {
        final userRecord = expandedUser.first;
        return _getSafeString(
          userRecord.data['username'],
          AppLocalizations.of(context)!.defaultUsername,
        );
      }
    } catch (e) {
      log('Error getting username from expanded user: $e');
    }
    return _getSafeString(
      video.data['username'],
      AppLocalizations.of(context)!.defaultUsername,
    ); // Fallback
  }

  String _getUserAvatarFromVideo(RecordModel video) {
    try {
      final expandedUser = video.expand['user'];
      if (expandedUser is List && expandedUser!.isNotEmpty) {
        final userRecord = expandedUser.first;
        final avatar = _getSafeStringOrNull(userRecord.data['avatar']);
        if (avatar != null && avatar.isNotEmpty) {
          return _getFileUrl(userRecord, avatar);
        }
      }
    } catch (e) {
      log('Error getting avatar from expanded user: $e');
    }
    return widget.profileImageUrl; // Fallback to current profile image
  }

  String _getFileUrl(RecordModel record, String filename) {
    return _pb.files.getUrl(record, filename).toString();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profileUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text(appLocalizations.profile)),
        body: Center(child: Text(appLocalizations.userNotFound)),
      );
    }

    final currentUser = _pb.authStore.record;
    final isCurrentUser =
        currentUser != null &&
        _profileUser != null &&
        currentUser.id == _profileUser!.id;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(appLocalizations.profile),
          actions: [
            if (isCurrentUser)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DownloadsScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: CachedNetworkImageProvider(
                          _profileUser!.getStringValue('avatar').isNotEmpty
                              ? _pb.files
                                    .getUrl(
                                      _profileUser!,
                                      _profileUser!.getStringValue('avatar'),
                                    )
                                    .toString()
                              : widget.profileImageUrl,
                        ),
                      ),
                      if (isCurrentUser)
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _showImagePickerOptions,
                        ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_profileUser != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FollowersScreen(
                                        userId: _profileUser!.id,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: FutureBuilder<int>(
                                future: _followersCountFuture,
                                builder: (context, snapshot) {
                                  return Text(
                                    '${snapshot.data ?? 0} ${appLocalizations.followers}',
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (_profileUser != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FollowingScreen(
                                        userId: _profileUser!.id,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: FutureBuilder<int>(
                                future: _followingCountFuture,
                                builder: (context, snapshot) {
                                  return Text(
                                    '${snapshot.data ?? 0} ${appLocalizations.following}',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (!isCurrentUser)
                          ElevatedButton(
                            onPressed: _toggleFollow,
                            child: Text(
                              _isFollowing
                                  ? appLocalizations.unfollow
                                  : appLocalizations.follow,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                Tab(
                  icon: const Icon(Icons.video_library),
                  text: appLocalizations.uploaded,
                ),
                Tab(
                  icon: const Icon(Icons.favorite),
                  text: appLocalizations.liked,
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Uploaded Videos
                  FutureBuilder<List<RecordModel>>(
                    future: _uploadedVideosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            appLocalizations.error(snapshot.error.toString()),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(appLocalizations.noUploadedVideos),
                        );
                      } else {
                        final uploadedVideos = snapshot.data!;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.7,
                                mainAxisSpacing: 2.0,
                                crossAxisSpacing: 2.0,
                              ),
                          itemCount: uploadedVideos.length,
                          itemBuilder: (context, index) {
                            final video = uploadedVideos[index];
                            final thumbnailUrl = _getFileUrl(
                              video,
                              video.data['thumbnail'] as String,
                            );
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      appBar: AppBar(),
                                      body: VideoPlayerItem(
                                        videoId: video.id,
                                        videoUrl: _getFileUrl(
                                          video,
                                          video.data['video'] as String,
                                        ),
                                        username: _getUsernameFromVideo(video),
                                        caption:
                                            video.data['caption'] as String,
                                        profileImageUrl:
                                            _getUserAvatarFromVideo(video),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl: thumbnailUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[800]),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                  // Liked Videos
                  FutureBuilder<List<RecordModel>>(
                    future: _likedVideosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            appLocalizations.error(snapshot.error.toString()),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(appLocalizations.noLikedVideos),
                        );
                      } else {
                        final likedVideos = snapshot.data!;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.7,
                                mainAxisSpacing: 2.0,
                                crossAxisSpacing: 2.0,
                              ),
                          itemCount: likedVideos.length,
                          itemBuilder: (context, index) {
                            final video = likedVideos[index];
                            final thumbnailUrl = _getFileUrl(
                              video,
                              video.data['thumbnail'] as String,
                            );
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      appBar: AppBar(),
                                      body: VideoPlayerItem(
                                        videoId: video.id,
                                        videoUrl: _getFileUrl(
                                          video,
                                          video.data['video'] as String,
                                        ),
                                        username:
                                            video.data['username'] as String,
                                        caption:
                                            video.data['caption'] as String,
                                        profileImageUrl:
                                            video.data['user_avatar'] as String,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl: thumbnailUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[800]),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: !isCurrentUser
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ConversationScreen(userId: _profileUser!.id),
                    ),
                  );
                },
                child: const Icon(Icons.chat_outlined),
              )
            : null,
      ),
    );
  }
}
