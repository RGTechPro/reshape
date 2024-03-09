part of '../chat_repository.dart';

class GptMessage {
  final String role;
  final String content;

  GptMessage({
    required this.role,
    required this.content,
  });

  factory GptMessage.fromJson(Map<String, dynamic> json) {
    return GptMessage(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role'] = this.role;
    data['content'] = this.content;
    return data;
  }
}