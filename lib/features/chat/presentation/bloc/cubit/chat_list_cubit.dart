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
  late final Stream<List<ChatUser>> _usersStream;
  ChatListCubit({required this.repository}) : super(ChatListLoading());

  void loadUsers(String currentUserId) {
    _usersStream = repository.getAllUsers(currentUserId);
    _usersStream.listen(
      (users) {
        emit(ChatListLoaded(users));
      },
      onError: (e) {
        emit(ChatListError(e.toString()));
      },
    );
  }
}
