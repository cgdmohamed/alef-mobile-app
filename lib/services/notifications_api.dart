import 'api_client.dart';

class ApiNotification {
  final String id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  bool read;

  ApiNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.read,
  });

  factory ApiNotification.fromJson(Map<String, dynamic> json) => ApiNotification(
        id: json['id'],
        title: json['title'],
        subtitle: json['subtitle'],
        createdAt: DateTime.parse(json['createdAt']),
        read: json['read'] ?? false,
      );
}

class NotificationsApi {
  NotificationsApi._();
  static final NotificationsApi instance = NotificationsApi._();
  final _client = ApiClient.instance;

  Future<List<ApiNotification>> list() async {
    final data = await _client.get('/notifications');
    return (data as List).map((e) => ApiNotification.fromJson(e)).toList();
  }

  Future<void> markRead(String id) => _client.patch('/notifications/$id/read');
  Future<void> markAllRead() => _client.post('/notifications/read-all');
  Future<int> unreadCount() async {
    final data = await _client.get('/notifications/unread-count');
    return data['count'] ?? 0;
  }
}
