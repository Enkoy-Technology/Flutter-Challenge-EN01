enum ChatMessageType { text, audio, video, picture }

extension ChatMessageTypeX on ChatMessageType {
  bool get isText => ChatMessageType.text == this;
  bool get isAudio => ChatMessageType.audio == this;
  bool get isVideo => ChatMessageType.video == this;
  bool get isPicture => ChatMessageType.picture == this;
}
