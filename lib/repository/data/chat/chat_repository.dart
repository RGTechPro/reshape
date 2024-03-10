import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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

  @override
  Future<Result<GetSpeechFromTextSuccess, GetSpeechFromTextFailure>>
      getSpeechFromText({required GetSpeechFromTextRequest request}) async {
    try {
      final _dioClient = await _network.secureClient(
          options: DioOptions(
        baseUrl: AppEnvironment.config.openApiUrl,
        headers: AppNetworkingBox.defaults.defaultHeaders,
        responseType: ResponseType.bytes,
      ));

      final response = await _dioClient?.post(
        _EndPoints.textToSpeech,
        data: request.toPayload(),
      );

      if (response?.statusCode == 200 && response?.data != null) {
        final data = response?.data;
        return Success(GetSpeechFromTextSuccess(speech: data));
      } else {
        return Failure(GetSpeechFromTextFailure(
            message:
                'Failed to get speech from text. Status code: ${response?.statusCode}'));
      }
    } catch (e) {
      return Failure(
          GetSpeechFromTextFailure(message: 'Failed to get speech from text.'));
    }
  }

  @override
  Future<Result<GetTextFromSpeechSuccess, GetTextFromSpeechFailure>>
      getTextFromSpeech({required GetTextFromSpeechRequest request}) async {
    try {
      final _dioClient = await _network.secureClient(
          options: DioOptions(
        baseUrl: AppEnvironment.config.openApiUrl,
        headers: AppNetworkingBox.defaults.multipartHeader,
      ));
print(request.toPayload());
      final response = await _dioClient?.post(
        _EndPoints.speechToText,
        data: FormData.fromMap(request.toPayload(),),
      );

      if (response?.statusCode == 200 && response?.data != null) {
        final data = jsonDecode(jsonEncode(response?.data));
        return Success(GetTextFromSpeechSuccess(text: data['text']));
      } else {
        return Failure(GetTextFromSpeechFailure(
            message:
                'Failed to get text from speech. Status code: ${response?.statusCode}'));
      }
    } catch (e) {
      return Failure(
          GetTextFromSpeechFailure(message: 'Failed to get text from speech.'));
    }
  }
}
