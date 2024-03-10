part of 'chat_repository.dart';

class GetGptResponseRequest extends RepositoryRequest {
  final List<GptMessage> messages;

  GetGptResponseRequest({
    required this.messages,
  });

  @override
  Map<String, dynamic> toPayload({Map<String, dynamic>? parameters}) {
    return {
      'model': 'gpt-3.5-turbo',
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }
}

class GetSpeechFromTextRequest extends RepositoryRequest {
  final String text;

  GetSpeechFromTextRequest({
    required this.text,
  });

  @override
  Map<String, dynamic> toPayload({Map<String, dynamic>? parameters}) {
    return {
      'model': 'tts-1',
      'voice': "nova",
      'input': text,
    };
  }
}

class GetTextFromSpeechRequest extends RepositoryRequest {
  final MultipartFile audioFile;

  GetTextFromSpeechRequest({
    required this.audioFile,

  });

  @override
  Map<String, dynamic> toPayload({Map<String, dynamic>? parameters})  {
    return {
      "model": "whisper-1",
      'file': audioFile ,
    };
  }
}
