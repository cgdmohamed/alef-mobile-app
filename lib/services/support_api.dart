import 'api_client.dart';

class ApiSupportMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  ApiSupportMessage({required this.id, required this.senderId, required this.text, required this.createdAt});

  factory ApiSupportMessage.fromJson(Map<String, dynamic> json) => ApiSupportMessage(
        id: json['id'],
        senderId: json['sender']?['id'] ?? '',
        text: json['text'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class SupportApi {
  SupportApi._();
  static final SupportApi instance = SupportApi._();
  final _client = ApiClient.instance;

  Future<String> myConversationId() async {
    final data = await _client.get('/support/conversations/mine');
    return data['id'];
  }

  Future<List<ApiSupportMessage>> messages(String conversationId) async {
    final data = await _client.get('/support/conversations/$conversationId/messages');
    return (data as List).map((e) => ApiSupportMessage.fromJson(e)).toList();
  }

  Future<ApiSupportMessage> sendMessage(String conversationId, String text) async {
    final data = await _client.post('/support/conversations/$conversationId/messages', {'text': text});
    return ApiSupportMessage.fromJson(data);
  }
}
