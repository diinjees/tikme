import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:tikme/models/comment.dart';
import 'package:tikme/services/auth_service.dart';
import 'package:pocketbase/pocketbase.dart';

class CommentProvider with ChangeNotifier {
  late final PocketBase _pb;
  final String _postId;
  List<Comment> _comments = [];
  UnsubscribeFunc? _commentUnsubscribe;

  List<Comment> get comments => _comments;

  CommentProvider(AuthService authService, this._postId)
    : _pb = authService.pb {
    _init();
  }

  void _init() {
    fetchComments();
    _subscribeToComments();
  }

  Future<void> fetchComments() async {
    try {
      final records = await _pb
          .collection('comments')
          .getFullList(
            filter: 'post="$_postId"',
            expand: 'user',
            sort: '-created',
          );

      _comments = records.map((record) {
        // Correctly extract the user record from the 'expand' field, which is a list.
        RecordModel user = RecordModel.fromJson({}); // Default empty record
        if (record.data.containsKey('expand') &&
            record.data['expand'] is Map &&
            record.data['expand']['user'] is List &&
            (record.data['expand']['user'] as List).isNotEmpty) {
          user = RecordModel.fromJson(record.data['expand']['user'][0]);
        }
        developer.log(
          'Extracted user: ${user.toJson()}',
          name: 'CommentProvider',
        );
        return Comment.fromRecord(record, user);
      }).toList();

      notifyListeners();
    } catch (e, s) {
      developer.log(
        'Error fetching comments',
        name: 'CommentProvider',
        level: 900,
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> addComment(String text) async {
    final currentUser = _pb.authStore.record;
    developer.log('fiedl or users: ${currentUser?.id}');
    if (currentUser == null) return;

    try {
      await _pb
          .collection('comments')
          .create(
            body: {'post': _postId, 'user': currentUser.id, 'comment': text},
          );

      // Re-fetch comments to ensure the list is updated after a new comment is added
      await fetchComments();
    } catch (e, s) {
      developer.log(
        'Error adding comment',
        name: 'CommentProvider',
        level: 900,
        error: e,
        stackTrace: s,
      );
      rethrow; // Rethrow to let the UI handle error display
    }
  }

  void _subscribeToComments() {
    _pb
        .collection('comments')
        .subscribe('post="$_postId"', (e) async {
          if (e.record == null) return; // Ensure record is not null

          final record = e.record!;
          // Fetch with expand: 'user' to ensure we have the user data
          final fullRecord = await _pb
              .collection('comments')
              .getOne(record.id, expand: 'user');
          final user = fullRecord.get<RecordModel>('expand.user');
          final updatedComment = Comment.fromRecord(fullRecord, user);

          if (e.action == 'create') {
            _comments.insert(
              0,
              updatedComment,
            ); // Add to the beginning for newest first
            notifyListeners();
          } else if (e.action == 'update') {
            final index = _comments.indexWhere(
              (comment) => comment.id == updatedComment.id,
            );
            if (index != -1) {
              _comments[index] = updatedComment;
              notifyListeners();
            }
          } else if (e.action == 'delete') {
            _comments.removeWhere((comment) => comment.id == updatedComment.id);
            notifyListeners();
          }
        })
        .then((unsubscribe) {
          _commentUnsubscribe = unsubscribe;
        })
        .catchError((e, s) {
          developer.log(
            'Error subscribing to comments',
            name: 'CommentProvider',
            level: 900,
            error: e,
            stackTrace: s,
          );
        });
  }

  @override
  void dispose() {
    _commentUnsubscribe?.call();
    super.dispose();
  }
}
