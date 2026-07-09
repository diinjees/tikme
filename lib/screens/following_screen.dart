import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FollowingScreen extends StatefulWidget {
  final String userId;

  const FollowingScreen({super.key, required this.userId});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  late final PocketBase _pb;
  late Future<List<RecordModel>> _followingFuture;
  late Future<List<String>> _followingIdsFuture;
  final Set<String> _followingIds = {};

  @override
  void initState() {
    super.initState();
    _pb = Provider.of<AuthService>(context, listen: false).pb;
    _followingFuture = _fetchFollowing();
    _followingIdsFuture = _fetchFollowingIds();
  }

  Future<List<RecordModel>> _fetchFollowing() async {
    try {
      final user = await _pb
          .collection('users')
          .getOne(widget.userId, expand: 'following');
      final following = user.getListValue<RecordModel>('expand.following');
      return following;
    } catch (e) {
      // Handle error
      return [];
    }
  }

  Future<List<String>> _fetchFollowingIds() async {
    final currentUser = _pb.authStore.record;
    if (currentUser == null) return [];

    try {
      final user = await _pb
          .collection('users')
          .getOne(currentUser.id, expand: 'following');
      final following = user.getListValue<RecordModel>('expand.following');
      final ids = following.map((e) => e.id).toList();
      setState(() {
        _followingIds.clear();
        _followingIds.addAll(ids);
      });
      return ids;
    } catch (e) {
      return [];
    }
  }

  String _getProfileImageUrl(RecordModel user) {
    final avatar = user.getStringValue('avatar');
    if (avatar.isNotEmpty) {
      return _pb.files.getUrl(user, avatar).toString();
    }
    return 'https://www.gravatar.com/avatar/?d=mp';
  }

  Future<void> _toggleFollow(String userIdToFollow) async {
    final currentUser = _pb.authStore.record;
    if (currentUser == null || currentUser.id == userIdToFollow) return;

    final isCurrentlyFollowing = _followingIds.contains(userIdToFollow);

    // Optimistic UI update
    setState(() {
      if (isCurrentlyFollowing) {
        _followingIds.remove(userIdToFollow);
      } else {
        _followingIds.add(userIdToFollow);
      }
    });

    try {
      // Update current user's following list
      final currentUserFollowing =
          (await _pb.collection('users').getOne(currentUser.id))
              .getListValue<String>('following');
      if (isCurrentlyFollowing) {
        currentUserFollowing.remove(userIdToFollow);
      } else {
        currentUserFollowing.add(userIdToFollow);
      }
      await _pb
          .collection('users')
          .update(currentUser.id, body: {'following': currentUserFollowing});

      // Update followed user's followers list
      final followedUserFollowers =
          (await _pb.collection('users').getOne(userIdToFollow))
              .getListValue<String>('followers');
      if (isCurrentlyFollowing) {
        followedUserFollowers.remove(currentUser.id);
      } else {
        followedUserFollowers.add(currentUser.id);
      }
      await _pb
          .collection('users')
          .update(userIdToFollow, body: {'followers': followedUserFollowers});
    } catch (e) {
      // Revert UI on error
      setState(() {
        if (isCurrentlyFollowing) {
          _followingIds.add(userIdToFollow);
        } else {
          _followingIds.remove(userIdToFollow);
        }
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedfollow(
                isCurrentlyFollowing
                    ? AppLocalizations.of(context)!.unfollow
                    : AppLocalizations.of(context)!.follow,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _pb.authStore.record?.id;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.following)),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_followingFuture, _followingIdsFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(AppLocalizations.of(context)!.errorfollowing),
            );
          }
          final following = snapshot.data?[0] as List<RecordModel>?;
          if (following == null || following.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.nofollowings),
            );
          }

          return ListView.builder(
            itemCount: following.length,
            itemBuilder: (context, index) {
              final followedUser = following[index];
              final isFollowing = _followingIds.contains(followedUser.id);
              final isCurrentUser = currentUserId == followedUser.id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    _getProfileImageUrl(followedUser),
                  ),
                ),
                title: Text(followedUser.getStringValue('username')),
                trailing: isCurrentUser
                    ? null
                    : ElevatedButton(
                        onPressed: () => _toggleFollow(followedUser.id),
                        child: Text(
                          isFollowing
                              ? AppLocalizations.of(context)!.unfollow
                              : AppLocalizations.of(context)!.follow,
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
