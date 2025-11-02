import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/util/constants.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/upload_media_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';

class ChatController extends GetxController {
  final SendMessageUsecase sendMessageUsecase;
  final GetMessagesUsecase getMessagesUsecase;
  final UploadMediaUsecase uploadMediaUsecase;
  final MarkAsReadUsecase markAsReadUsecase;
  final AuthRemoteDataSource authDataSource;

  
  final messages = RxList<MessageEntity>();
  final isLoading = false.obs;
  final isUploading = false.obs;
  final uploadProgress = 0.0.obs;
  final isSending = false.obs;
  final error = Rx<String?>(null);

  late ScrollController scrollController;
  late TextEditingController messageController;
  late FocusNode messageFocusNode;

  String? chatRoomId;
  String? currentUserId;
  String? otherUserId;
  String? senderName;
  String? senderPhotoUrl;

  ChatController({
    required this.sendMessageUsecase,
    required this.getMessagesUsecase,
    required this.uploadMediaUsecase,
    required this.markAsReadUsecase,
    required this.authDataSource,
  });

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    messageController = TextEditingController();
    messageFocusNode = FocusNode();

    
    Future.microtask(() => _initializeChatData());
  }

  void _initializeChatData() {
    try {
      chatRoomId = Get.arguments?['chatRoomId'];
      currentUserId = Get.arguments?['currentUserId'];
      otherUserId = Get.arguments?['otherUserId'];
      senderName = Get.arguments?['senderName'];
      senderPhotoUrl = Get.arguments?['senderPhotoUrl'];

      _loadMessages();
      _setupScrollListener();
    } catch (e) {
      error.value = 'Failed to initialize chat: ${e.toString()}';
    }
  }

  void _loadMessages() {
    if (chatRoomId == null) return;

    try {
      getMessagesUsecase(chatRoomId!).listen(
        (messageList) {
          
          final sortedMessages = messageList
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

          messages.assignAll(sortedMessages);

          
          for (var message in sortedMessages) {
            if (message.senderId != currentUserId &&
                message.status != 'read' &&
                !(message.readBy.contains(currentUserId))) {
              _markAsRead(message.id);
            }
          }

          
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        },
        onError: (e) {
          error.value = 'Failed to load messages: ${e.toString()}';
        },
      );
    } catch (e) {
      error.value = 'Error in _loadMessages: ${e.toString()}';
    }
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.hasClients &&
          scrollController.position.maxScrollExtent ==
              scrollController.offset) {
        _loadMoreMessages();
      }
    });
  }

  Future<void> _loadMoreMessages() async {
    if (chatRoomId == null || messages.isEmpty) return;

    try {
      final lastMessage = messages.last;

      final olderMessages = await getMessagesUsecase.getPaginated(
        chatRoomId!,
        limit: Constants.messagePageSize,
        lastMessage: lastMessage,
      );

      if (olderMessages.isNotEmpty) {
        messages.addAll(olderMessages);
      }
    } catch (e) {
      error.value = 'Failed to load more messages: ${e.toString()}';
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.isEmpty || chatRoomId == null || currentUserId == null) return;

    try {
      isSending.value = true;
      final messageId = const Uuid().v4();

      final message = MessageEntity(
        id: messageId,
        senderId: currentUserId!,
        senderName: senderName ?? 'Unknown',
        senderPhotoUrl: senderPhotoUrl,
        chatRoomId: chatRoomId!,
        content: content,
        type: Constants.messageTypeText,
        timestamp: DateTime.now(),
        status: Constants.messageStatusSent,
        readBy: [currentUserId!],
      );

      await sendMessageUsecase(message);
      messageController.clear();
      _scrollToBottom();
      error.value = null;
    } catch (e) {
      error.value = 'Failed to send message: ${e.toString()}';
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendImage() async {
    try {
      final status = await Permission.photos.request();

      if (!status.isGranted) {
        error.value = 'Photo permission denied';
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final fileSize = await File(pickedFile.path).length();
      if (fileSize > Constants.maxImageSize) {
        error.value = 'Image size exceeds 5MB limit';
        return;
      }

      await _uploadAndSendMedia(
        pickedFile.path,
        Constants.messageTypeImage,
        'image/jpeg',
      );
    } catch (e) {
      error.value = 'Failed to select image: ${e.toString()}';
    }
  }

  Future<void> sendCamera() async {
    try {
      final status = await Permission.camera.request();

      if (!status.isGranted) {
        error.value = 'Camera permission denied';
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) return;

      await _uploadAndSendMedia(
        pickedFile.path,
        Constants.messageTypeImage,
        'image/jpeg',
      );
    } catch (e) {
      error.value = 'Failed to take photo: ${e.toString()}';
    }
  }

  Future<void> _uploadAndSendMedia(
    String filePath,
    String mediaType,
    String mimeType,
  ) async {
    try {
      isUploading.value = true;
      final messageId = const Uuid().v4();

      
      final mediaUrl = await uploadMediaUsecase(filePath, messageId);

      
      final message = MessageEntity(
        id: messageId,
        senderId: currentUserId!,
        senderName: senderName ?? 'Unknown',
        senderPhotoUrl: senderPhotoUrl,
        chatRoomId: chatRoomId!,
        content: '[${mediaType.toUpperCase()}]',
        type: mediaType,
        timestamp: DateTime.now(),
        status: Constants.messageStatusSent,
        readBy: [currentUserId!],
        mediaUrl: mediaUrl,
        mediaType: mimeType,
      );

      await sendMessageUsecase(message);
      _scrollToBottom();
      error.value = null;
    } catch (e) {
      error.value = 'Failed to upload media: ${e.toString()}';
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  Future<void> _markAsRead(String messageId) async {
    try {
      await markAsReadUsecase(messageId, currentUserId!);
    } catch (e) {
      
      print('Error marking message as read: $e');
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void deleteMessage(String messageId) async {
    try {
      
    } catch (e) {
      error.value = 'Failed to delete message: ${e.toString()}';
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }
}
