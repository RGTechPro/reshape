import 'package:reshape/repository/data/chat/chat_repository.dart';
import 'package:reshape/repository/repository.dart';


part 'requests.dart';
part 'response.dart';
part 'models/gpt_message.dart';
part 'models/chatX.dart';

abstract class ChatRepository extends Repository {
  factory ChatRepository() =>ChatRepositoryImpl();

  Future<Result<GetGptResponseSuccess, GetGptResponseFailure>> getGptResponse({
    required GetGptResponseRequest request,
  });

}
