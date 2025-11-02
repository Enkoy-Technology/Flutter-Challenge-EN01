import '../repositories/chat_repository.dart';

class UploadMediaUsecase {
  final ChatRepository repository;

  UploadMediaUsecase(this.repository);

  Future<String> call(String filePath, String messageId) async {
    return await repository.uploadMedia(filePath, messageId);
  }
}
