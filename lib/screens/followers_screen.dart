import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;

  const FollowersScreen({super.key, required this.userId});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  late final PocketBase _pb;
  late Future<List<RecordModel>> _followersFuture;
  late Future<List<String>> _followingIdsFuture;
  final Set<String> _followingIds = {};

  @override
  void initState() {
    super.initState();
    _pb = Provider.of<AuthService>(context, listen: false).pb;
    _followersFuture = _fetchFollowers();
    _followingIdsFuture = _fetchFollowingIds();
  }

  Future<List<RecordModel>> _fetchFollowers() async {
    try {
      final user = await _pb
          .collection('users')
          .getOne(widget.userId, expand: 'followers');
      final followers = user.getListValue<RecordModel>('expand.followers');
      return followers;
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

    try {
      final isCurrentlyFollowing = _followingIds.contains(userIdToFollow);

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

      setState(() {
        if (isCurrentlyFollowing) {
          _followingIds.remove(userIdToFollow);
        } else {
          _followingIds.add(userIdToFollow);
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _pb.authStore.record?.id;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.followers)),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_followersFuture, _followingIdsFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(AppLocalizations.of(context)!.errorfollower),
            );
          }
          final followers = snapshot.data?[0] as List<RecordModel>?;
          if (followers == null || followers.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.nofollowers),
            );
          }

          return ListView.builder(
            itemCount: followers.length,
            itemBuilder: (context, index) {
              final follower = followers[index];
              final isFollowing = _followingIds.contains(follower.id);
              final isCurrentUser = currentUserId == follower.id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    _getProfileImageUrl(follower),
                  ),
                ),
                title: Text(follower.getStringValue('username')),
                trailing: isCurrentUser
                    ? null
                    : ElevatedButton(
                        onPressed: () => _toggleFollow(follower.id),
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
