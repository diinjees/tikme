import 'package:pocketbase/pocketbase.dart';

class Comment {
  final String id;
  final String username;
  final String comment;
  final DateTime timestamp;
  final String userId;
  final String userAvatar;

  Comment({
    required this.id,
    required this.username,
    required this.comment,
    required this.timestamp,
    required this.userId,
    required this.userAvatar,
  });

  factory Comment.fromRecord(RecordModel record, RecordModel user) {
    final userAvatar = user.getStringValue('avatar');
    final avatarUrl = user.getStringValue('avatar').isNotEmpty
        ? 'https://metube.pockethost.io/api/files/users/${user.id}/$userAvatar'
        : 'https://www.gravatar.com/avatar/?d=mp';

    return Comment(
      id: record.id,
      username: user.getStringValue('username'),
      comment: record.getStringValue('comment'),
      timestamp: DateTime.parse(record.get<String>('created')),
      userId: user.id,
      userAvatar: avatarUrl,
    );
  }
}
