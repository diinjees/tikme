// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tikme/services/auth_service.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatService {
  // ignore: unused_field
  final AuthService _authService;
  final PocketBase _pb;
  final String _currentUserId;

  ChatService(this._authService)
    : _pb = _authService.pb,
      _currentUserId = _authService.pb.authStore.record!.id;

  String get currentUserId => _currentUserId;
  PocketBase get pb => _pb;

  // Sanitize filename to remove problematic characters
  String _sanitizeFilename(String filePath) {
    final file = File(filePath);
    final originalName = file.uri.pathSegments.last;

    // Remove brackets, spaces, and other problematic characters
    final sanitizedName = originalName
        .replaceAll(RegExp(r'[\[\](){}]'), '') // Remove brackets
        .replaceAll(' ', '_') // Replace spaces with underscores
        .replaceAll(
          RegExp(r'[^a-zA-Z0-9._-]'),
          '',
        ) // Remove other special chars
        .toLowerCase();

    return sanitizedName;
  }

  // Get user details by ID
  Future<RecordModel> getUserById(String userId) async {
    return await _pb.collection('users').getOne(userId);
  }

  // Get a list of conversations
  Future<List<RecordModel>> getConversations() async {
    final records = await _pb
        .collection('messages')
        .getFullList(
          filter: 'sender = "$_currentUserId" || receiver = "$_currentUserId"',
          sort: '-created',
          expand: 'sender,receiver',
        );

    final conversations = <String, RecordModel>{};
    for (final record in records) {
      final senderId = record.expand['sender']![0].id;
      final receiverId = record.expand['receiver']![0].id;
      final otherUserId = senderId == _currentUserId ? receiverId : senderId;

      if (!conversations.containsKey(otherUserId)) {
        conversations[otherUserId] = record;
      }
    }

    return conversations.values.toList();
  }

  // Get messages for a specific conversation
  Stream<List<RecordModel>> getMessages(String otherUserId) {
    final controller = StreamController<List<RecordModel>>();

    void fetchAndAddMessages() {
      _pb
          .collection('messages')
          .getFullList(
            filter:
                '(sender = "$_currentUserId" && receiver = "$otherUserId") || (sender = "$otherUserId" && receiver = "$_currentUserId")',
            sort: 'created',
            expand: 'sender,receiver',
          )
          .then((records) {
            controller.add(records);
          });
    }

    fetchAndAddMessages(); // Initial fetch

    _pb.collection('messages').subscribe('*', (e) {
      if (e.action == 'create' || e.action == 'update') {
        fetchAndAddMessages();
      }
    });

    return controller.stream;
  }

  // Send a text message with optional reply
  Future<void> sendMessage(
    String otherUserId,
    String text, {
    String? replyToId,
    String? replyText,
    String? replyType,
  }) async {
    final body = {
      'sender': _currentUserId,
      'receiver': otherUserId,
      'text': text,
      'type': 'text',
      'status': 'sent', // Initial status is 'sent'
    };

    // Add reply information if provided
    if (replyToId != null && replyToId.isNotEmpty) {
      body['reply_to'] = replyToId;
      body['reply_text'] = replyText ?? '';
      body['reply_type'] = replyType ?? 'text';
    }

    await _pb.collection('messages').create(body: body);
  }

  // Send an image message with optional reply
  Future<void> sendImageMessage(
    String receiverId,
    File imageFile, {
    String? replyToId,
    String? replyText,
    String? replyType,
    String? texT_m,
  }) async {
    try {
      final sanitizedFilename = _sanitizeFilename(imageFile.path);
      final multipartFile = await http.MultipartFile.fromPath(
        'media',
        imageFile.path,
        filename: sanitizedFilename, // Provide sanitized filename
      );

      final body = {
        'sender': _currentUserId,
        'receiver': receiverId,
        'type': 'image',
        'text': '📷 Image',
        'status': 'sent',
        'text_m': texT_m,
      };

      // Add reply information if provided
      if (replyToId != null && replyToId.isNotEmpty) {
        body['reply_to'] = replyToId;
        body['reply_text'] = replyText ?? '';
        body['reply_type'] = replyType ?? 'text';
      }

      await _pb
          .collection('messages')
          .create(body: body, files: [multipartFile]);
    } catch (e) {
      throw Exception('Failed to send image: $e');
    }
  }

  // Send a video message with optional reply
  Future<void> sendVideoMessage(
    String receiverId,
    File videoFile, {
    String? replyToId,
    String? replyText,
    String? replyType,
    String? texT_m,
  }) async {
    try {
      final sanitizedFilename = _sanitizeFilename(videoFile.path);
      final multipartFile = await http.MultipartFile.fromPath(
        'media',
        videoFile.path,
        filename: sanitizedFilename, // Provide sanitized filename
      );

      final body = {
        'sender': _currentUserId,
        'receiver': receiverId,
        'type': 'video',
        'text': '🎥 Video',
        'status': 'sent',
        'text_m': texT_m,
      };

      // Add reply information if provided
      if (replyToId != null && replyToId.isNotEmpty) {
        body['reply_to'] = replyToId;
        body['reply_text'] = replyText ?? '';
        body['reply_type'] = replyType ?? 'text';
      }

      await _pb
          .collection('messages')
          .create(body: body, files: [multipartFile]);
    } catch (e) {
      throw Exception('Failed to send video: $e');
    }
  }

  // Send a document message with optional reply
  Future<void> sendDocumentMessage(
    String receiverId,
    File documentFile, {
    String? replyToId,
    String? replyText,
    String? replyType,
    String? texT_m,
  }) async {
    try {
      final sanitizedFilename = _sanitizeFilename(documentFile.path);
      final multipartFile = await http.MultipartFile.fromPath(
        'media',
        documentFile.path,
        filename: sanitizedFilename, // Provide sanitized filename
      );

      final body = {
        'sender': _currentUserId,
        'receiver': receiverId,
        'type': 'document',
        'text': '📄 Document',
        'status': 'sent',
        'text_m': texT_m,
      };

      // Add reply information if provided
      if (replyToId != null && replyToId.isNotEmpty) {
        body['reply_to'] = replyToId;
        body['reply_text'] = replyText ?? '';
        body['reply_type'] = replyType ?? 'text';
      }

      await _pb
          .collection('messages')
          .create(body: body, files: [multipartFile]);
    } catch (e) {
      throw Exception('Failed to send document: $e');
    }
  }

  // Helper method to get proper media URL
  String getMediaUrl(RecordModel message) {
    try {
      final mediaFileName = message.getStringValue('media');
      final collectionId = message.collectionId;
      final recordId = message.id;

      if (mediaFileName.isEmpty) return '';

      // Clean filename by removing square brackets
      final cleanFileName = mediaFileName
          .replaceAll('[', '')
          .replaceAll(']', '');

      // Use proper URL encoding for the filename
      final encodedFileName = Uri.encodeComponent(cleanFileName);
      return '${_pb.baseUrl}/api/files/$collectionId/$recordId/$encodedFileName';
    } catch (e) {
      return '';
    }
  }

  // Get replied message details
  Future<RecordModel?> getRepliedMessage(String messageId) async {
    try {
      return await _pb.collection('messages').getOne(messageId);
    } catch (e) {
      return null;
    }
  }

  Future<RecordModel?> getRepliedImage(String messageId) async {
    try {
      if (messageId.isEmpty) return null;

      final message = await _pb.collection('messages').getOne(messageId);

      return message;
    } catch (e) {
      print('Error fetching replied message info: $e');
      return null;
    }
  }

  // Update message status to 'received'
  Future<void> markMessageAsReceived(String messageId) async {
    await _pb
        .collection('messages')
        .update(messageId, body: {'status': 'received'});
  }

  // Update messages from a specific sender to 'seen'
  Future<void> markMessagesAsSeen(String senderId, String receiverId) async {
    final records = await _pb
        .collection('messages')
        .getFullList(
          filter:
              'sender = "$senderId" && receiver = "$receiverId" && status != "seen"',
        );
    for (final record in records) {
      await _pb
          .collection('messages')
          .update(record.id, body: {'status': 'seen'});
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    await _pb.collection('messages').delete(messageId);
  }

  // Delete all messages sent by the current user in a specific conversation
  Future<void> deleteAllMyMessagesInConversation(String otherUserId) async {
    final records = await _pb
        .collection('messages')
        .getFullList(
          filter: 'sender = "$_currentUserId" && receiver = "$otherUserId"',
        );
    for (final record in records) {
      await _pb.collection('messages').delete(record.id);
    }
  }

  // Delete a conversation (all messages between two users)
  Future<void> deleteConversation(String otherUserId) async {
    final records = await _pb
        .collection('messages')
        .getFullList(
          filter:
              '(sender = "$_currentUserId" && receiver = "$otherUserId") || (sender = "$otherUserId" && receiver = "$_currentUserId")',
        );

    for (final record in records) {
      await _pb.collection('messages').delete(record.id);
    }
  }

  // delete multiple conversations
  Future<void> deleteConversations(List<String> otherUserIds) async {
    for (final otherUserId in otherUserIds) {
      await deleteConversation(otherUserId);
    }
  }

  // delete all conversations
  Future<void> deleteAllConversations() async {
    final records = await _pb
        .collection('messages')
        .getFullList(
          filter: 'sender = "$_currentUserId" || receiver = "$_currentUserId"',
        );

    for (final record in records) {
      await _pb.collection('messages').delete(record.id);
    }
  }
}
