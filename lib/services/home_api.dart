import 'api_client.dart';

class StudentHomeData {
  final String studentName;
  final int points;
  final Map<String, dynamic>? nextMeeting;
  final List<dynamic> pendingAssignments;
  final int unreadNotifications;

  StudentHomeData({
    required this.studentName,
    required this.points,
    required this.nextMeeting,
    required this.pendingAssignments,
    required this.unreadNotifications,
  });

  factory StudentHomeData.fromJson(Map<String, dynamic> json) => StudentHomeData(
        studentName: json['student']?['name'] ?? '',
        points: json['student']?['points'] ?? 0,
        nextMeeting: json['nextMeeting'],
        pendingAssignments: json['pendingAssignments'] ?? [],
        unreadNotifications: json['unreadNotifications'] ?? 0,
      );
}

class ParentHomeChild {
  final String id;
  final String? userId;
  final String name;
  final String stage;
  final int average;
  final int points;
  final bool consentPending;

  ParentHomeChild({required this.id, required this.userId, required this.name, required this.stage, required this.average, required this.points, required this.consentPending});

  factory ParentHomeChild.fromJson(Map<String, dynamic> json) => ParentHomeChild(
        id: json['id'],
        userId: json['userId'],
        name: json['name'],
        stage: json['stage'] ?? '',
        average: json['average'] ?? 0,
        points: json['points'] ?? 0,
        consentPending: json['consentPending'] ?? false,
      );
}

class ParentHomeData {
  final List<ParentHomeChild> children;
  final int unreadNotifications;

  ParentHomeData({required this.children, required this.unreadNotifications});

  factory ParentHomeData.fromJson(Map<String, dynamic> json) => ParentHomeData(
        children: (json['children'] as List? ?? []).map((e) => ParentHomeChild.fromJson(e)).toList(),
        unreadNotifications: json['unreadNotifications'] ?? 0,
      );
}

class HomeApi {
  HomeApi._();
  static final HomeApi instance = HomeApi._();
  final _client = ApiClient.instance;

  /// Returns null if this account has no linked student roster record.
  Future<StudentHomeData?> studentHome() async {
    try {
      final data = await _client.get('/home/student');
      return StudentHomeData.fromJson(data);
    } on ApiException {
      return null;
    }
  }

  Future<ParentHomeData> parentHome() async {
    final data = await _client.get('/home/parent');
    return ParentHomeData.fromJson(data);
  }
}
