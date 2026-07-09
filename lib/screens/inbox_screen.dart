// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/screens/conversation_screen.dart';
import 'package:tikme/services/chat_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late final ChatService _chatService;
  late Future<List<RecordModel>> _conversationsFuture;
  final Set<String> _selectedConversations = {};
  bool _isSelectionMode = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<ChatService>(context, listen: false);
    _conversationsFuture = _chatService.getConversations();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedConversations.clear();
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedConversations.clear();
    });
  }

  void _deleteSelectedConversations() async {
    if (_selectedConversations.isEmpty) return;

    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletemessages),
        content: Text(AppLocalizations.of(context)!.deleteMesDes),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.deletebutton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Future.wait(
        _selectedConversations.map(
          (userId) => _chatService.deleteConversation(userId),
        ),
      );
      setState(() {
        _conversationsFuture = _chatService.getConversations();
        _selectedConversations.clear();
        _isSelectionMode = false;
      });
    }
  }

  void _deleteAllConversations() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCon),
        content: Text(AppLocalizations.of(context)!.deleteConDes),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.deletebutton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _chatService.deleteAllConversations();
      setState(() {
        _conversationsFuture = _chatService.getConversations();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text(
                '${_selectedConversations.length} ${AppLocalizations.of(context)!.selected}',
              )
            : Text(AppLocalizations.of(context)!.inbox),
        actions: _isSelectionMode
            ? [
                if (_selectedConversations.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedConversations,
                  ),
                // Cancel button
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: _cancelSelection,
                  tooltip: AppLocalizations.of(context)!.cancelButton,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Implement search functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: _toggleSelectionMode,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: _deleteAllConversations,
                ),
              ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.searchM,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<RecordModel>>(
              future: _conversationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.nomessages),
                  );
                }
                final conversations = snapshot.data!
                    .where(
                      (c) =>
                          // ignore: deprecated_member_use
                          (c.expand['sender']![0]
                              .getStringValue('username')
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          // ignore: deprecated_member_use
                          c.expand['receiver']![0]
                              .getStringValue('username')
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase())),
                    )
                    .toList();

                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final sender = conversation.expand['sender']![0];
                    final receiver = conversation.expand['receiver']![0];
                    final otherUser = sender.id == _chatService.currentUserId
                        ? receiver
                        : sender;

                    final isSelected = _selectedConversations.contains(
                      otherUser.id,
                    );

                    return ListTile(
                      leading: _isSelectionMode
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked!) {
                                    _selectedConversations.add(otherUser.id);
                                  } else {
                                    _selectedConversations.remove(otherUser.id);
                                  }
                                });
                              },
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(
                                otherUser.getStringValue('avatar').isNotEmpty
                                    ? _chatService.pb.files
                                          .getUrl(
                                            otherUser,
                                            otherUser.getStringValue('avatar'),
                                          )
                                          .toString()
                                    : 'https://www.gravatar.com/avatar/?d=mp',
                              ),
                            ),
                      title: Text(otherUser.getStringValue('username')),
                      subtitle: Text(conversation.getStringValue('text')),
                      trailing: Text(conversation.created.substring(11, 16)),
                      onTap: () {
                        if (_isSelectionMode) {
                          setState(() {
                            if (isSelected) {
                              _selectedConversations.remove(otherUser.id);
                            } else {
                              _selectedConversations.add(otherUser.id);
                            }
                          });
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ConversationScreen(userId: otherUser.id),
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        if (!_isSelectionMode) {
                          _toggleSelectionMode();
                          _selectedConversations.add(otherUser.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
