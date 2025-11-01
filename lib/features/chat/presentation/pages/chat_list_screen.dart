import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/app_router.dart';
import '../../../../core/di/injector.dart';
import '../bloc/cubit/chat_list_cubit.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        'currentUserId'; // replace with real user id from AuthBloc

    return BlocProvider(
      create: (_) => sl<ChatListCubit>()..loadUsers(currentUserId),
      child: Scaffold(
        appBar: AppBar(title: const Text("Chats")),
        body: BlocBuilder<ChatListCubit, ChatListState>(
          builder: (context, state) {
            if (state is ChatListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatListLoaded) {
              final users = state.users;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(user.name),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.chatScreen,
                        arguments: {
                          'chatId': user.id,
                          'receiverName': user.name,
                        },
                      );
                    },
                  );
                },
              );
            } else if (state is ChatListError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
