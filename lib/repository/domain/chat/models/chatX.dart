part of '../chat_repository.dart';

class ChatResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final String systemFingerprint;
  final List<ChatChoice> choices;
  final ChatUsage usage;

  ChatResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.systemFingerprint,
    required this.choices,
    required this.usage,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      systemFingerprint: json['system_fingerprint'],
      choices: List<ChatChoice>.from(json['choices'].map((x) => ChatChoice.fromJson(x))),
      usage: ChatUsage.fromJson(json['usage']),
    );
  }
}

class ChatChoice {
  final int index;
  final GptMessage message;
  final dynamic logprobs; // You can replace `dynamic` with the appropriate type if logprobs have a specific structure
  final String finishReason;

  ChatChoice({
    required this.index,
    required this.message,
    required this.logprobs,
    required this.finishReason,
  });

  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      index: json['index'],
      message: GptMessage.fromJson(json['message']),
      logprobs: json['logprobs'],
      finishReason: json['finish_reason'],
    );
  }
}

class ChatUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  ChatUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory ChatUsage.fromJson(Map<String, dynamic> json) {
    return ChatUsage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }
}
