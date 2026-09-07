import 'api_client.dart';

class ApiBadge {
  final String emoji;
  final String label;
  final bool locked;

  ApiBadge({required this.emoji, required this.label, required this.locked});

  factory ApiBadge.fromJson(Map<String, dynamic> json) => ApiBadge(
        emoji: json['emoji'],
        label: json['label'],
        locked: json['locked'] ?? true,
      );
}

class AchievementsApi {
  AchievementsApi._();
  static final AchievementsApi instance = AchievementsApi._();
  final _client = ApiClient.instance;

  Future<List<ApiBadge>> myAchievements() async {
    final data = await _client.get('/students/me/achievements');
    return (data as List).map((e) => ApiBadge.fromJson(e)).toList();
  }
}
