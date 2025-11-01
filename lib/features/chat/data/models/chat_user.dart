class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;

  ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.lastMessage = '',
    DateTime? lastMessageTime,
  }) : lastMessageTime =
           lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);

  factory ChatUser.fromMap(Map<String, dynamic> map, String docId) {
    return ChatUser(
      id: docId,
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'],
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'])
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
