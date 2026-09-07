import 'package:flutter/material.dart';
import '../../services/reports_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/misc.dart';

/// `reportId == 'me'` shows the authenticated student's own report
/// (`/students/me/report`). Any other value is treated as a child's roster
/// id and fetched via `/reports/students/:id`, which the backend only
/// allows for a parent who has completed consent for that specific child.
class ReportDetailScreen extends StatefulWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool _loading = true;
  StudentReportSummary? _report;

  @override
  void initState() {
    super.initState();
    final future = widget.reportId == 'me'
        ? ReportsApi.instance.myReport()
        : ReportsApi.instance.childReport(widget.reportId);
    future.then((data) {
      if (mounted) {
        setState(() {
          _report = data;
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    final report = _report;
    if (report == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
                child: Row(children: [const BackChevron(), const SizedBox(width: 6), Text('التقرير', style: tj(14, weight: FontWeight.w700, color: AppColors.textHeading))]),
              ),
              Expanded(
                child: StateMessage(
                  icon: Text('!', style: tj(40, color: AppColors.textFaint)),
                  iconBg: AppColors.inputFill,
                  title: 'لا يوجد تقرير بعد',
                  subtitle: '',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
              child: Row(
                children: [
                  const BackChevron(),
                  const SizedBox(width: 6),
                  Text('تقرير ${report.name}', style: tj(14, weight: FontWeight.w700, color: AppColors.textHeading)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _MiniStat(value: '${report.average}%', label: 'المتوسط', color: AppColors.primary)),
                        const SizedBox(width: 8),
                        Expanded(child: _MiniStat(value: '${report.attendancePercent}%', label: 'الحضور', color: AppColors.sky)),
                        const SizedBox(width: 8),
                        Expanded(child: _MiniStat(value: '${report.points}', label: 'النقاط', color: AppColors.warning)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('الواجبات المسلّمة', style: tj(11, weight: FontWeight.w700, color: AppColors.textHeading)),
                    const SizedBox(height: 8),
                    if (report.submissions.isEmpty)
                      Text('لا توجد واجبات مسلّمة بعد', style: tj(11, color: AppColors.textFaint))
                    else
                      for (final s in report.submissions.cast<Map<String, dynamic>>()) ...[
                        AppCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(s['title']?.toString() ?? '', style: tj(11, color: AppColors.textBody))),
                              if (s['grade'] != null) Text('${s['grade']}%', style: tj(11, weight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    const SizedBox(height: 16),
                    Text('سجل الحضور', style: tj(11, weight: FontWeight.w700, color: AppColors.textHeading)),
                    const SizedBox(height: 8),
                    if (report.attendance.isEmpty)
                      Text('لا يوجد سجل حضور بعد', style: tj(11, color: AppColors.textFaint))
                    else
                      for (final a in report.attendance.cast<Map<String, dynamic>>()) ...[
                        AppCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(a['title']?.toString() ?? '', style: tj(11, color: AppColors.textBody))),
                              Text(a['status']?.toString() ?? '', style: tj(11, color: AppColors.textFaint)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MiniStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(color: AppColors.screenBg, borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(value, style: tj(15, weight: FontWeight.w800, color: color)),
          Text(label, style: tj(8, color: AppColors.textFaint)),
        ],
      ),
    );
  }
}
