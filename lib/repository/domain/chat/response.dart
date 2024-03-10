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

class GetTextFromSpeechSuccess extends RepositorySuccess {
  final String text;

  GetTextFromSpeechSuccess({
    required this.text,
  });

}

class GetTextFromSpeechFailure extends RepositoryFailure {
  GetTextFromSpeechFailure({
     String? message,
  }) : super(message: message);
}
