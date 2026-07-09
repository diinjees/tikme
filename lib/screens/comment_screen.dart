import 'package:flutter/material.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/providers/comment_provider.dart';
import 'package:tikme/screens/profile_screen.dart';
import 'package:tikme/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentScreen extends StatefulWidget {
  final String postId;
  final FocusNode? focusNode;

  const CommentScreen({super.key, required this.postId, this.focusNode});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  late final TextEditingController _commentController;
  bool _isSending = false; // To track if a comment is being sent

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    // Request focus if a focusNode is provided
    if (widget.focusNode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.focusNode!.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment(CommentProvider commentProvider) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await commentProvider.addComment(text);

      _commentController.clear();
      // Check if the widget is still mounted before using context
      if (!mounted) return;
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToPostComment(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          CommentProvider(context.read<AuthService>(), widget.postId),
      child: Consumer<CommentProvider>(
        builder: (context, commentProvider, child) {
          final comments = commentProvider.comments;

          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.comments)),
            body: Column(
              children: [
                Expanded(
                  child: comments.isEmpty
                      ? Center(
                          child: comments.isEmpty
                              ? Text(AppLocalizations.of(context)!.noComments)
                              : CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                        username: comment.username,
                                        profileImageUrl: comment.userAvatar,
                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    comment.userAvatar,
                                  ),
                                ),
                              ),
                              title: Text(comment.username),
                              subtitle: Text(comment.comment),
                              trailing: Text(timeago.format(comment.timestamp)),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          focusNode: widget.focusNode,
                          autofocus: widget.focusNode != null,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.addComment,
                          ),
                          onSubmitted: (_) => _postComment(commentProvider),
                        ),
                      ),
                      IconButton(
                        icon: _isSending
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        onPressed: _isSending
                            ? null
                            : () => _postComment(commentProvider),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
