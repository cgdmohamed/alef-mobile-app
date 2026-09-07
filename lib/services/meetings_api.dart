import 'api_client.dart';

class ApiMeeting {
  final String id;
  final String title;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status; // scheduled | live | ended
  final String className;
  final String? teacherName;

  ApiMeeting({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    required this.className,
    required this.teacherName,
  });

  factory ApiMeeting.fromJson(Map<String, dynamic> json) {
    final classEntity = json['classEntity'] as Map<String, dynamic>?;
    return ApiMeeting(
      id: json['id'],
      title: json['title'],
      scheduledAt: DateTime.parse(json['scheduledAt']),
      durationMinutes: json['durationMinutes'],
      status: json['status'],
      className: classEntity?['name'] ?? '',
      teacherName: classEntity?['teacher']?['name'],
    );
  }
}

/// Credentials for joining an Agora RTC channel — a fresh, short-lived
/// token minted per join attempt (see the backend's AgoraRtcProvider), not
/// a static URL. `uid` is always 0 (wildcard) — the Agora SDK assigns the
/// actual numeric uid client-side on join.
class AgoraJoinCredentials {
  final String channelName;
  final String token;
  final String appId;
  final int uid;

  AgoraJoinCredentials({required this.channelName, required this.token, required this.appId, required this.uid});

  factory AgoraJoinCredentials.fromJson(Map<String, dynamic> json) => AgoraJoinCredentials(
        channelName: json['channelName'],
        token: json['token'],
        appId: json['appId'],
        uid: json['uid'] ?? 0,
      );
}

class ApiRecording {
  final String title;
  final String playbackUrl;
  final int durationSeconds;
  final int views;

  ApiRecording({required this.title, required this.playbackUrl, required this.durationSeconds, required this.views});

  factory ApiRecording.fromJson(Map<String, dynamic> json) => ApiRecording(
        title: json['title'],
        playbackUrl: json['playbackUrl'],
        durationSeconds: json['durationSeconds'] ?? 0,
        views: json['views'] ?? 0,
      );
}

class MeetingsApi {
  MeetingsApi._();
  static final MeetingsApi instance = MeetingsApi._();
  final _client = ApiClient.instance;

  Future<List<ApiMeeting>> list({String? scope}) async {
    final data = await _client.get('/meetings${scope != null ? '?scope=$scope' : ''}');
    return (data as List).map((e) => ApiMeeting.fromJson(e)).toList();
  }

  Future<ApiRecording?> recording(String meetingId) async {
    try {
      final data = await _client.get('/meetings/$meetingId/recording');
      return ApiRecording.fromJson(data);
    } on ApiException {
      return null;
    }
  }

  Future<AgoraJoinCredentials> join(String meetingId) async {
    final data = await _client.post('/meetings/$meetingId/join');
    return AgoraJoinCredentials.fromJson(data);
  }
}
