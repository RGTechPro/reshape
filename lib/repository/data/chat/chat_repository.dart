import 'dart:convert';

import 'package:reshape/environment/environment.dart';
import 'package:reshape/modules/core/data/network/dio/dio.dart';
import 'package:reshape/modules/core/domain/network/network.dart';

import '../../domain/chat/chat_repository.dart';
import '../../repository.dart';

part 'end_points.dart';

class ChatRepositoryImpl implements ChatRepository {
  final _network = AppNetworkingBox.instance;
  @override
  Future<Result<GetGptResponseSuccess, GetGptResponseFailure>> getGptResponse({
    required GetGptResponseRequest request,
  }) async {
    try {
      final _dioClient = await _network.secureClient(
          options: DioOptions(
        baseUrl: AppEnvironment.config.openApiUrl,
        headers: AppNetworkingBox.defaults.defaultHeaders,
      ));

      final response = await _dioClient?.post(
        _EndPoints.chatCompletion,
        data: request.toPayload(),
      );

      if (response?.statusCode == 200 && response?.data != null) {
        final data = jsonDecode(jsonEncode(response?.data));

        return Success(
            GetGptResponseSuccess(chatResponse: ChatResponse.fromJson(data)));
      } else {
        return Failure(GetGptResponseFailure(
            message:
                'Failed to get GPT response. Status code: ${response?.statusCode}'));
      }
    } catch (e) {
      return Failure(
          GetGptResponseFailure(message: 'Failed to get GPT response.'));
    }
  }
}
