part of 'chat_repository.dart';

class GetGptResponseSuccess extends RepositorySuccess {
  final ChatResponse chatResponse;

  GetGptResponseSuccess({
    required this.chatResponse,
  });


}

class GetGptResponseFailure extends RepositoryFailure {
  GetGptResponseFailure({
     String? message,
  }) : super(message: message);
}


class GetSpeechFromTextSuccess extends RepositorySuccess {
  final Uint8List speech;

  GetSpeechFromTextSuccess({
    required this.speech,
  });

}

class GetSpeechFromTextFailure extends RepositoryFailure {
  GetSpeechFromTextFailure({
     String? message,
  }) : super(message: message);
}
