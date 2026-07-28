import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/misc.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _tab = 0;
  static const _tabs = ['الشهرية', 'الفصلية', 'الختامية'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          children: [
            Text('التقارير', style: tj(20, weight: FontWeight.w800, color: AppColors.textHeading)),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: StatTile(value: '91%', label: 'متوسط الأداء', valueColor: AppColors.primary, valueSize: 16)),
                SizedBox(width: 8),
                Expanded(child: StatTile(value: '96%', label: 'الحضور', valueColor: AppColors.sky, valueSize: 16)),
                SizedBox(width: 8),
                Expanded(child: StatTile(value: '12', label: 'الإنجازات', valueColor: AppColors.warning, valueSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('نشاط آخر 7 أيام', style: tj(11, weight: FontWeight.w700, color: AppColors.textHeading)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 72,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < MockData.weeklyActivity.length; i++)
                          Container(
                            width: 26,
                            height: 72 * MockData.weeklyActivity[i],
                            decoration: BoxDecoration(
                              color: i == 2 || i == 5 ? AppColors.primary : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final d in MockData.weekDayLabels) Text(d, style: tj(8, color: AppColors.textDisabled)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _tab == i ? AppColors.primary : Colors.transparent, width: 2))),
                        child: Text(_tabs[i], style: tj(12, weight: _tab == i ? FontWeight.w700 : FontWeight.w400, color: _tab == i ? AppColors.primary : AppColors.textFaint)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (final r in MockData.monthlyReports) ...[
              GestureDetector(
                onTap: () => context.push('/report/r1'),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(9)),
                        alignment: Alignment.center,
                        child: Text('PDF', style: tj(9, color: AppColors.coral)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title, style: tj(12, weight: FontWeight.w700, color: AppColors.textBody)),
                            Text(r.meta, style: tj(10, color: AppColors.textFaint)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
