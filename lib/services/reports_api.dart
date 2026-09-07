import 'api_client.dart';

class StudentReportSummary {
  final String name;
  final int average;
  final int attendancePercent;
  final int points;
  final List<dynamic> submissions;
  final List<dynamic> attendance;

  StudentReportSummary({
    required this.name,
    required this.average,
    required this.attendancePercent,
    required this.points,
    required this.submissions,
    required this.attendance,
  });

  factory StudentReportSummary.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? {};
    return StudentReportSummary(
      name: json['student']?['name'] ?? '',
      average: summary['average'] ?? 0,
      attendancePercent: summary['attendancePercent'] ?? 0,
      points: summary['points'] ?? 0,
      submissions: json['submissions'] ?? [],
      attendance: json['attendance'] ?? [],
    );
  }
}

class ReportsApi {
  ReportsApi._();
  static final ReportsApi instance = ReportsApi._();
  final _client = ApiClient.instance;

  Future<StudentReportSummary?> myReport() async {
    try {
      final data = await _client.get('/students/me/report');
      return StudentReportSummary.fromJson(data);
    } on ApiException {
      return null;
    }
  }

  /// Used by a parent viewing one specific child's report. The backend
  /// enforces that a parent can only fetch a child they've completed
  /// consent for (403 otherwise); returns null if the child/report isn't
  /// found or isn't accessible.
  Future<StudentReportSummary?> childReport(String studentId) async {
    try {
      final data = await _client.get('/reports/students/$studentId');
      return StudentReportSummary.fromJson(data);
    } on ApiException {
      return null;
    }
  }
}
