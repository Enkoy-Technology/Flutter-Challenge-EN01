import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/chat/data/models/chat_user.dart';
import '../../../domain/repositories/chat_repository.dart';

abstract class ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatUser> users;
  ChatListLoaded(this.users);
}

class ChatListError extends ChatListState {
  final String message;
  ChatListError(this.message);
}

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepository repository;
  StreamSubscription? _usersSubscription;

  ChatListCubit({required this.repository}) : super(ChatListLoading());

  void loadUsers(String currentUserId) {
    // Cancel any existing subscription
    _usersSubscription?.cancel();

    emit(ChatListLoading());

    _usersSubscription = repository
        .getAllUsersWithRealtimeLastMessage(currentUserId)
        .listen(
          (users) {
            // ✅ Sort by lastMessageTime (most recent first)
            users.sort((a, b) {
              final aTime =
                  a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bTime =
                  b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bTime.compareTo(aTime);
            });

            emit(ChatListLoaded(users));
          },
          onError: (e) {
            emit(ChatListError(e.toString()));
          },
        );
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }
}
