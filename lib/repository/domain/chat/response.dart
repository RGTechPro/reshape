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
