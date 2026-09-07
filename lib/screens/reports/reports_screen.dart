import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/reports_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/misc.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _loading = true;
  String? _error;
  StudentReportSummary? _report;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ReportsApi.instance.myReport();
      if (!mounted) return;
      setState(() {
        _report = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل التقرير';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null
                ? StateMessage(
                    icon: Text('!', style: tj(40, color: AppColors.coral)),
                    iconBg: AppColors.dangerBg,
                    title: 'تعذر تحميل التقرير',
                    subtitle: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
                    actionLabel: 'إعادة المحاولة',
                    onAction: _load,
                  )
                : _report == null
                    ? StateMessage(
                        icon: Text('!', style: tj(40, color: AppColors.textFaint)),
                        iconBg: AppColors.inputFill,
                        title: 'لا يوجد تقرير بعد',
                        subtitle: 'سيظهر تقريرك هنا بعد إكمال بعض الواجبات واللقاءات',
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                          children: [
                            Text('التقارير', style: tj(20, weight: FontWeight.w800, color: AppColors.textHeading)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: StatTile(value: '${_report!.average}%', label: 'متوسط الأداء', valueColor: AppColors.primary, valueSize: 16, labelSize: 9)),
                                const SizedBox(width: 8),
                                Expanded(child: StatTile(value: '${_report!.attendancePercent}%', label: 'الحضور', valueColor: AppColors.sky, valueSize: 16, labelSize: 9)),
                                const SizedBox(width: 8),
                                Expanded(child: StatTile(value: '${_report!.points}', label: 'النقاط', valueColor: AppColors.warning, valueSize: 16, labelSize: 9)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => context.push('/report/me'),
                              child: AppCard(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('التقرير التفصيلي', style: tj(12, weight: FontWeight.w700, color: AppColors.textBody)),
                                          Text('${_report!.submissions.length} واجب مسلّم', style: tj(10, color: AppColors.textFaint)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
