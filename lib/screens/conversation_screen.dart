import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/services/chat_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class ConversationScreen extends StatefulWidget {
  final String userId;
  final String? lastMessage;

  const ConversationScreen({super.key, required this.userId, this.lastMessage});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late final ChatService _chatService;
  late final String _currentUserId;
  RecordModel? _otherUser;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingUser = true;
  bool _isUploading = false;
  File? _pendingMediaFile;
  String _pendingMediaType = 'image';
  RecordModel? _replyingToMessage;
  RecordModel? _image_reply;

  final Set<String> _selectedMessages = {};
  bool _isSelecting = false;

  // Cache for optimized performance
  final Map<String, String> _mediaUrlCache = {};
  final Map<String, String> _formattedTimeCache = {};
  final Map<String, Widget> _messageBubbleCache = {};

  // Offline storage
  late Box _localMessagesBox;
  bool _isInitializingStorage = true;

  // Video player
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatService = Provider.of<ChatService>(context, listen: false);
    _currentUserId = _chatService.currentUserId;
    _initializeLocalStorage();
    _fetchOtherUserDetails();
    _scrollToBottom();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _mediaUrlCache.clear();
    _formattedTimeCache.clear();
    _messageBubbleCache.clear();
    _videoController?.dispose();
    _localMessagesBox.close();
    super.dispose();
  }

  Future<void> _initializeLocalStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
      _localMessagesBox = await Hive.openBox('messages_${widget.userId}');
      setState(() {
        _isInitializingStorage = false;
      });
    } catch (e) {
      setState(() {
        _isInitializingStorage = false;
      });
    }
  }

  Future<void> _saveMessageLocally(RecordModel message) async {
    try {
      await _localMessagesBox.put(message.id, {
        'id': message.id,
        'sender': message.getStringValue('sender'),
        'text': message.getStringValue('text'),
        'type': message.getStringValue('type'),
        'media': message.getStringValue('media'),
        'status': message.getStringValue('status'),
        'created': message.created,
        'text_m': message.data['text_m']?.toString() ?? '',
        'reply_to': message.getStringValue('reply_to'),
        'reply_text': message.getStringValue('reply_text'),
        'reply_type': message.getStringValue('reply_type'),
      });
    } catch (e) {}
  }

  List<RecordModel> _getLocalMessages() {
    if (_isInitializingStorage) return [];

    final localMessages = _localMessagesBox.values.toList();
    return localMessages.map((data) {
      // Create a RecordModel using the correct constructor
      // For most PocketBase versions, we need to use fromJson or create a map
      final recordData = {
        'id': data['id'],
        'collectionId': 'messages',
        'collectionName': 'messages',
        'created': data['created'],
        'updated': data['created'],
        'sender': data['sender'],
        'text': data['text'],
        'type': data['type'],
        'media': data['media'],
        'status': data['status'],
        'text_m': data['text_m'],
        'reply_to': data['reply_to'],
        'reply_text': data['reply_text'],
        'reply_type': data['reply_type'],
      };

      return RecordModel.fromJson(recordData);
    }).toList();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markMessagesAsSeen();
    } else if (state == AppLifecycleState.paused) {
      _videoController?.pause();
    }
  }

  Future<void> _markMessagesAsSeen() async {
    if (mounted) {
      await _chatService.markMessagesAsSeen(widget.userId, _currentUserId);
    }
  }

  Future<void> _fetchOtherUserDetails() async {
    try {
      final user = await _chatService.getUserById(widget.userId);
      if (mounted) {
        setState(() {
          _otherUser = user;
          _isLoadingUser = false;
        });
      }
      _markMessagesAsSeen();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty && _pendingMediaFile == null) {
      return;
    }

    final messageText = text.trim();

    try {
      if (_pendingMediaFile != null) {
        await _sendMediaMessage(messageText);
      } else {
        await _sendTextMessageWithReply(messageText);
      }

      // Clear everything after sending
      _textController.clear();
      _clearPendingMedia();
      _clearReply();
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackbar('Failed to send message');
    }
  }

  Future<void> _sendTextMessageWithReply(String text) async {
    if (_replyingToMessage != null) {
      await _chatService.sendMessage(
        widget.userId,
        text,
        replyToId: _replyingToMessage!.id,
        replyText: _replyingToMessage!.getStringValue('text'),
        replyType: _replyingToMessage!.getStringValue('type'),
      );
    } else {
      await _chatService.sendMessage(widget.userId, text);
    }
  }

  Future<void> _sendMediaMessage(String? text) async {
    if (_pendingMediaFile == null) return;

    try {
      setState(() => _isUploading = true);

      final String? replyToId;
      final String? replyText;
      final String? replyType;

      if (_replyingToMessage != null) {
        replyToId = _replyingToMessage!.id;
        replyText = _replyingToMessage!.getStringValue('text');
        replyType = _replyingToMessage!.getStringValue('type');
      } else {
        replyToId = null;
        replyText = null;
        replyType = null;
      }

      switch (_pendingMediaType) {
        case 'image':
          await _chatService.sendImageMessage(
            widget.userId,
            _pendingMediaFile!,
            replyToId: replyToId,
            replyText: replyText,
            replyType: replyType,
            texT_m: text,
          );
          break;
        case 'video':
          await _chatService.sendVideoMessage(
            widget.userId,
            _pendingMediaFile!,
            replyToId: replyToId,
            replyText: replyText,
            replyType: replyType,
            texT_m: text,
          );
          break;
        case 'document':
          await _chatService.sendDocumentMessage(
            widget.userId,
            _pendingMediaFile!,
            replyToId: replyToId,
            replyText: replyText,
            replyType: replyType,
            texT_m: text,
          );
          break;
      }

      setState(() => _isUploading = false);
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorSnackbar('Failed to send media');
    }
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
      );

      if (image != null && mounted) {
        setState(() {
          _pendingMediaFile = File(image.path);
          _pendingMediaType = 'image';
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image');
    }
  }

  Future<void> _pickAndSendVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null && mounted) {
        setState(() {
          _pendingMediaFile = File(video.path);
          _pendingMediaType = 'video';
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick video');
    }
  }

  Future<void> _pickAndSendDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'zip', 'rar'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null && mounted) {
        setState(() {
          _pendingMediaFile = File(result.files.single.path!);
          _pendingMediaType = 'document';
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick document');
    }
  }

  void _clearPendingMedia() {
    if (mounted) {
      setState(() {
        _pendingMediaFile = null;
        _pendingMediaType = 'image';
      });
    }
  }

  void _clearReply() {
    if (mounted) {
      setState(() {
        _replyingToMessage = null;
      });
    }
  }

  void _setReplyMessage(RecordModel message) {
    if (_isSelecting || !mounted) return;

    setState(() {
      _replyingToMessage = message;
    });
  }

  void _toggleMessageSelection(String messageId) {
    if (!mounted) return;

    setState(() {
      if (_selectedMessages.contains(messageId)) {
        _selectedMessages.remove(messageId);
      } else {
        _selectedMessages.add(messageId);
      }
      _isSelecting = _selectedMessages.isNotEmpty;
    });
  }

  void _clearSelection() {
    if (mounted) {
      setState(() {
        _selectedMessages.clear();
        _isSelecting = false;
      });
    }
  }

  void _deleteSelectedMessages() async {
    if (_selectedMessages.isEmpty) return;

    final shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletemessages),
        content: Text('Delete ${_selectedMessages.length} selected messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.deletemessages),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      for (final messageId in _selectedMessages) {
        await _chatService.deleteMessage(messageId);
        await _localMessagesBox.delete(messageId);
      }
      _clearSelection();
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: Text(AppLocalizations.of(context)!.photoLibrary),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.blue),
                title: Text(AppLocalizations.of(context)!.camera),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.purple),
                title: Text(AppLocalizations.of(context)!.video),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file, color: Colors.orange),
                title: Text(AppLocalizations.of(context)!.document),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendDocument();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cached media URL getter - FIXED VERSION
  String _getCachedMediaUrl(RecordModel message) {
    final messageId = message.id;
    if (_mediaUrlCache.containsKey(messageId)) {
      return _mediaUrlCache[messageId]!;
    }

    final mediaUrl = _chatService.getMediaUrl(message);

    // Fix for the "No host specified in URI" error
    if (mediaUrl.startsWith('file://') && !mediaUrl.contains(':///')) {
      _mediaUrlCache[messageId] = '';
      return '';
    }

    _mediaUrlCache[messageId] = mediaUrl;
    return mediaUrl;
  }

  // Safe avatar URL getter
  String? _getSafeAvatarUrl(RecordModel? user) {
    if (user == null) return null;

    try {
      final avatar = user.getStringValue('avatar');
      if (avatar.isEmpty) return null;

      final avatarUrl = _chatService.pb.files.getUrl(user, avatar).toString();
      if (avatarUrl.startsWith('file://') && !avatarUrl.contains(':///')) {
        return null;
      }

      return avatarUrl;
    } catch (e) {
      return null;
    }
  }

  // Cached time formatter
  String _getCachedFormattedTime(String created) {
    if (_formattedTimeCache.containsKey(created)) {
      return _formattedTimeCache[created]!;
    }

    final formattedTime = _formatMessageTime(created);
    _formattedTimeCache[created] = formattedTime;
    return formattedTime;
  }

  Widget _buildReplyPreview() {
    if (_replyingToMessage == null) return const SizedBox.shrink();

    final message = _replyingToMessage!;
    final isMe = message.getStringValue('sender') == _currentUserId;
    final messageText = message.getStringValue('text');
    final messageType = message.getStringValue('type');
    final hasMedia = message.getStringValue('media').isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          if (hasMedia && (messageType == 'image' || messageType == 'video'))
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[300],
              ),
              child: messageType == 'image'
                  ? _buildReplyImageThumbnail(message)
                  : Icon(Icons.play_arrow, color: Colors.grey[600]),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${isMe ? 'You' : _otherUser?.getStringValue('username') ?? 'User'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  messageType == 'text'
                      ? messageText
                      : messageType == 'image'
                      ? '📷 Image'
                      : messageType == 'video'
                      ? '🎥 Video'
                      : messageType == 'document'
                      ? '📄 Document'
                      : 'Media',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: _clearReply,
          ),
        ],
      ),
    );
  }

  _image(String replyIoId) async {
    final dat = await _chatService.getRepliedImage(replyIoId);
    return dat == _image_reply;
  }

  Widget _buildReplyImageThumbnail(RecordModel message) {
    final mediaUrl = _getCachedMediaUrl(message);
    if (mediaUrl.isEmpty) {
      return Icon(Icons.image, color: Colors.grey[600]);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        mediaUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.image, color: Colors.grey[600]);
        },
      ),
    );
  }

  Widget _buildPendingMediaPreview() {
    if (_pendingMediaFile == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _pendingMediaType == 'image'
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: FileImage(_pendingMediaFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : _pendingMediaType == 'video'
              ? Container(
                  width: 40,
                  height: 40,
                  color: Colors.black45,
                  child: const Icon(Icons.videocam, color: Colors.white),
                )
              : Icon(
                  Icons.insert_drive_file,
                  size: 40,
                  color: Colors.grey[600],
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pendingMediaType == 'image'
                      ? 'Image'
                      : _pendingMediaType == 'video'
                      ? 'Video'
                      : _pendingMediaFile?.path.split('/').last ?? 'Document',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (_pendingMediaType == 'document')
                  Text(
                    '${(_pendingMediaFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _clearPendingMedia,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(RecordModel message, bool isMe) {
    final messageId = message.id;

    // Return cached widget if available and not selected
    final isSelected = _selectedMessages.contains(messageId);
    if (!isSelected && _messageBubbleCache.containsKey(messageId)) {
      return _messageBubbleCache[messageId]!;
    }

    final messageType = message.getStringValue('type');
    final messageStatus = message.getStringValue('status');
    final messageText = message.getStringValue('text');
    final hasMedia = message.getStringValue('media').isNotEmpty;
    final replyToId = message.getStringValue('reply_to');
    final replyText = message.getStringValue('reply_text');
    final replyType = message.getStringValue('reply_type');

    final bubbleWidget = GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (_isSelecting) return;
        if (details.delta.dx > 10) {
          _setReplyMessage(message);
        }
      },
      onLongPress: () => _toggleMessageSelection(messageId),
      onTap: () {
        if (_isSelecting) {
          _toggleMessageSelection(messageId);
        } else if (hasMedia) {
          if (messageType == 'video') {
            _playVideo(message);
          } else if (messageType == 'image') {
            _showFullScreenImage(_getCachedMediaUrl(message));
          } else if (messageType == 'document') {
            _showDocumentInfo(message);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPress: () => _toggleMessageSelection(messageId),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3)
                            : isMe
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.9)
                            : Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (hasMedia && messageType == 'image')
                            _buildImageMessage(message, isMe)
                          else if (hasMedia && messageType == 'video')
                            _buildVideoMessage(message, isMe)
                          else if (hasMedia && messageType == 'document')
                            _buildDocumentMessage(message, isMe)
                          else if (messageText.isNotEmpty)
                            Container(
                              constraints: const BoxConstraints(
                                maxHeight: 1000,
                                maxWidth: 200,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (replyToId.isNotEmpty)
                                    _buildMessageReplyPreview(
                                      replyText,
                                      replyType,
                                      isMe,
                                      message,
                                    ),
                                  Text(
                                    messageText,
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isMe) ...[
                        _buildMessageStatus(messageStatus, isMe),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _getCachedFormattedTime(message.created),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Cache the widget if not selected
    if (!isSelected) {
      _messageBubbleCache[messageId] = bubbleWidget;
    }

    return bubbleWidget;
  }

  Widget _buildMessageReplyPreview(
    String replyText,
    String replyType,
    bool isMe,
    RecordModel message,
  ) {
    final replyToId = message.getStringValue('reply_to');
    _image(replyToId);
    print("waa 123 : $_image_reply");
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
          if (replyToId.isNotEmpty &&
              (replyType == 'image' || replyType == 'video'))
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[300],
              ),
              child: replyType == 'image'
                  ? _buildReplyImageThumbnail(message)
                  : Icon(Icons.play_arrow, color: Colors.grey[600]),
            ),
          if (replyText != 'image' || replyType != 'video')
            const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  replyType == 'text'
                      ? replyText
                      : replyType == 'image'
                      ? '📷 Image'
                      : replyType == 'video'
                      ? '🎥 Video'
                      : replyType == 'document'
                      ? '📄 Document'
                      : 'Media',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(RecordModel message, bool isMe) {
    final mediaUrl = _getCachedMediaUrl(message);
    final text = message.data["text_m"]?.toString() ?? '';

    return GestureDetector(
      onTap: () => _showFullScreenImage(mediaUrl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: mediaUrl.isNotEmpty
                  ? Image.network(
                      mediaUrl,
                      fit: BoxFit.cover,
                      width: 200,
                      height: 200,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoMessage(RecordModel message, bool isMe) {
    final mediaUrl = _getCachedMediaUrl(message);
    final text = message.data["text_m"]?.toString() ?? '';

    return GestureDetector(
      onTap: () => _playVideo(message),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.black45,
                  child: mediaUrl.isNotEmpty
                      ? const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 50,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.videocam_off,
                              color: Colors.grey[500],
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Video not available',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
                if (mediaUrl.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            if (text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentMessage(RecordModel message, bool isMe) {
    final mediaUrl = _getCachedMediaUrl(message);
    final text = message.data["text_m"]?.toString() ?? '';
    final fileName = mediaUrl.isNotEmpty
        ? mediaUrl.split('/').last
        : 'Document';

    return GestureDetector(
      onTap: () => _showDocumentInfo(message),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName.length > 20
                              ? '${fileName.substring(0, 20)}...'
                              : fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Document',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.download,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            if (text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _playVideo(RecordModel message) async {
    final mediaUrl = _getCachedMediaUrl(message);
    if (mediaUrl.isEmpty) {
      _showErrorSnackbar('Video not available');
      return;
    }

    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.network(mediaUrl)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _showVideoPlayerDialog();
            _videoController!.play();
            _isVideoPlaying = true;
          }
        });
    } catch (e) {
      _showErrorSnackbar('Failed to play video');
    }
  }

  void _showVideoPlayerDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  _videoController?.pause();
                  _isVideoPlaying = false;
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      _videoController?.pause();
      _isVideoPlaying = false;
    });
  }

  void _showDocumentInfo(RecordModel message) {
    final mediaUrl = _getCachedMediaUrl(message);
    final fileName = mediaUrl.isNotEmpty
        ? mediaUrl.split('/').last
        : 'Unknown Document';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: $fileName'),
            const SizedBox(height: 8),
            Text('Type: ${message.getStringValue('type')}'),
            if (message.data["text_m"]?.toString().isNotEmpty ?? false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text('Caption:'),
                  Text(message.data["text_m"]?.toString() ?? ''),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (mediaUrl.isNotEmpty)
            TextButton(
              onPressed: () {
                // Implement download functionality
                _showSuccessSnackbar('Downloading document...');
                Navigator.pop(context);
              },
              child: const Text('Download'),
            ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      _showErrorSnackbar('Image not available');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Image.network(
                    imageUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(String created) {
    try {
      final dateTime = DateTime.parse(created);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return 'Now';
      if (difference.inHours < 1) return '${difference.inMinutes}m';
      if (difference.inDays < 1) return '${difference.inHours}h';
      if (difference.inDays < 7) return '${difference.inDays}d';

      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return created.length > 11 ? created.substring(11, 16) : created;
    }
  }

  Widget _buildMessageStatus(String status, bool isMe) {
    IconData icon;
    Color color = Colors.grey;

    if (isMe) {
      if (status == 'seen') {
        icon = Icons.done_all;
        color = Colors.blue;
      } else if (status == 'received') {
        icon = Icons.done_all;
        color = Colors.grey;
      } else {
        icon = Icons.done;
        color = Colors.grey;
      }

      return Icon(icon, size: 14, color: color);
    }

    return const SizedBox.shrink();
  }

  AppBar _buildSelectionAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: _clearSelection,
      ),
      title: Text(
        '${_selectedMessages.length} selected',
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.white),
          onPressed: _deleteSelectedMessages,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            _showErrorSnackbar('Share feature coming soon');
          },
        ),
      ],
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildReplyPreview(),
          _buildPendingMediaPreview(),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              if (!_isUploading) ...[
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _showAttachmentOptions,
                ),
                const SizedBox(width: 4),
              ],
              if (_isUploading) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
              Expanded(
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.sendMessage,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  maxLines: 5,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelecting
          ? _buildSelectionAppBar()
          : AppBar(
              title: Row(
                children: [
                  _isLoadingUser
                      ? Container(
                          width: 32,
                          height: 32,
                          padding: const EdgeInsets.all(4),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : CircleAvatar(
                          backgroundImage: _getSafeAvatarUrl(_otherUser) != null
                              ? NetworkImage(_getSafeAvatarUrl(_otherUser)!)
                              : null,
                          child: _getSafeAvatarUrl(_otherUser) == null
                              ? const Icon(Icons.person, size: 16)
                              : null,
                        ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoadingUser
                            ? AppLocalizations.of(context)!.defaultUsername
                            : _otherUser?.getStringValue('username') ??
                                  AppLocalizations.of(context)!.defaultUsername,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _isLoadingUser
                            ? ''
                            : AppLocalizations.of(context)!.online,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'info') {
                      // View profile
                    } else if (value == 'select_messages') {
                      setState(() {
                        _isSelecting = true;
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'info',
                      child: Text(AppLocalizations.of(context)!.viewProfile),
                    ),
                    PopupMenuItem(
                      value: 'select_messages',
                      child: const Text('Select Messages'),
                    ),
                  ],
                ),
              ],
            ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<RecordModel>>(
              stream: _chatService.getMessages(widget.userId),
              builder: (context, snapshot) {
                // Show local messages while loading or if offline
                final hasNetworkData = snapshot.hasData;
                final messages = hasNetworkData
                    ? snapshot.data!
                    : _getLocalMessages();

                if (_isInitializingStorage && !hasNetworkData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.nomessages,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        if (!hasNetworkData)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Offline Mode',
                              style: TextStyle(
                                color: Colors.orange[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (widget.lastMessage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Last message in conversation:',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.lastMessage!,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                // Save messages locally for offline access
                if (hasNetworkData) {
                  for (final message in messages) {
                    _saveMessageLocally(message);
                  }
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (hasNetworkData) {
                  _markMessagesAsSeen();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 8),
                  reverse: false,
                  itemBuilder: (_, int index) {
                    final message = messages[index];
                    final isMe =
                        message.getStringValue('sender') == _currentUserId;
                    return _buildMessageBubble(message, isMe);
                  },
                  itemCount: messages.length,
                );
              },
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }
}
