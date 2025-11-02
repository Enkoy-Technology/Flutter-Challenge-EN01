import 'package:get/get.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../core/services/storage_service.dart';

class ChatListController extends GetxController {
  final ChatRepository chatRepository;

  final chatRooms = RxList<ChatRoomEntity>();
  final isLoading = false.obs;
  final error = Rx<String?>(null);
  final searchQuery = ''.obs;

  late String currentUserId;

  ChatListController({required this.chatRepository});

  @override
  void onInit() {
    super.onInit();
    
    Future.microtask(() => _initializeData());
  }

  Future<void> _initializeData() async {
    try {
      isLoading.value = true;
      final storageService = Get.find<StorageService>();
      currentUserId = storageService.getUserId() ?? '';

      if (currentUserId.isEmpty) {
        error.value = 'User ID not found. Please login again.';
        return;
      }

      _loadChatRooms();
    } catch (e) {
      error.value = 'Initialization error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void _loadChatRooms() {
    try {
      
      chatRepository.getChatRooms(currentUserId).listen(
        (rooms) {
          
          
          rooms.sort(
            (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
          );
          
          chatRooms.assignAll(rooms);
          error.value = null; 
          
          
          if (rooms.isEmpty) {
          }
        },
        onError: (e) {
          error.value = 'Failed to load chats: ${e.toString()}';
        },
      );
    } catch (e) {
      error.value = 'Error loading chat rooms: ${e.toString()}';
    }
  }

  List<ChatRoomEntity> get filteredChatRooms {
    if (searchQuery.value.isEmpty) {
      return chatRooms.toList();
    }

    return chatRooms
        .where((room) => room.otherUserName
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      await chatRepository.deleteChatRoom(chatRoomId);
      chatRooms.removeWhere((room) => room.id == chatRoomId);
      error.value = null;
    } catch (e) {
      error.value = 'Failed to delete chat: ${e.toString()}';
    }
  }

  Future<void> refreshChatRooms() async {
    _loadChatRooms();
  }
}
