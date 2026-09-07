import 'api_client.dart';

class ApiAssignment {
  final String id;
  final String title;
  final String kind; // quiz | essay | puzzle
  final DateTime dueAt;
  final String? submissionStatus; // in_progress | submitted | late | graded | null (not started)
  final int? grade;

  ApiAssignment({
    required this.id,
    required this.title,
    required this.kind,
    required this.dueAt,
    required this.submissionStatus,
    required this.grade,
  });

  factory ApiAssignment.fromJson(Map<String, dynamic> json) {
    final submission = json['submission'] as Map<String, dynamic>?;
    return ApiAssignment(
      id: json['id'],
      title: json['title'],
      kind: json['kind'],
      dueAt: DateTime.parse(json['dueAt']),
      submissionStatus: submission?['status'],
      grade: submission?['grade'],
    );
  }
}

class ApiAssignmentResult {
  final String status;
  final int? grade;
  final String? teacherNote;

  ApiAssignmentResult({required this.status, required this.grade, required this.teacherNote});

  factory ApiAssignmentResult.fromJson(Map<String, dynamic> json) => ApiAssignmentResult(
        status: json['status'],
        grade: json['grade'],
        teacherNote: json['teacherNote'],
      );
}

class AssignmentsApi {
  AssignmentsApi._();
  static final AssignmentsApi instance = AssignmentsApi._();
  final _client = ApiClient.instance;

  Future<List<ApiAssignment>> myAssignments() async {
    final data = await _client.get('/students/me/assignments');
    return (data as List).map((e) => ApiAssignment.fromJson(e)).toList();
  }

  Future<void> submit(String assignmentId, Map<String, dynamic> answerPayload) async {
    await _client.post('/assignments/$assignmentId/submit', {'answerPayload': answerPayload});
  }

  /// Returns null if the submission hasn't been graded yet (backend 404s).
  Future<ApiAssignmentResult?> result(String assignmentId) async {
    try {
      final data = await _client.get('/assignments/$assignmentId/result');
      return ApiAssignmentResult.fromJson(data);
    } on ApiException {
      return null;
    }
  }
}
