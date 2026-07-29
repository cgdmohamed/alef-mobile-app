import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';

class ReportDetailScreen extends StatelessWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
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
                  Text('تقرير يوليو الشهري', style: tj(14, weight: FontWeight.w700, color: AppColors.textHeading)),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset('assets/avatars/lama.png', width: 44, height: 44, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('لمى عبدالله الحربي', style: tj(13, weight: FontWeight.w700, color: AppColors.textBody)),
                            Text('الصف السادس ابتدائي', style: tj(10, color: AppColors.textFaint)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Expanded(child: _MiniStat(value: '91%', label: 'المتوسط', color: AppColors.primary)),
                        SizedBox(width: 8),
                        Expanded(child: _MiniStat(value: '96%', label: 'الحضور', color: AppColors.sky)),
                        SizedBox(width: 8),
                        Expanded(child: _MiniStat(value: '12', label: 'شارات', color: AppColors.warning)),
                        SizedBox(width: 8),
                        Expanded(child: _MiniStat(value: '5', label: 'المستوى', color: AppColors.coral)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('درجات المهارات', style: tj(11, weight: FontWeight.w700, color: AppColors.textHeading)),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        for (final s in MockData.skillScores) ...[
                          LabeledProgress(
                            label: s.label,
                            percent: s.percent,
                            color: s.color,
                            labelSize: 9,
                            trackHeight: 6,
                            gap: 2,
                          ),
                          if (s != MockData.skillScores.last) const SizedBox(height: 7),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('نقاط القوة', style: tj(10, weight: FontWeight.w700, color: AppColors.success)),
                                const SizedBox(height: 5),
                                Text('التفكير النقدي، حل المشكلات، الالتزام بالمواعيد', style: tj(9, color: const Color(0xFF3A7A57), height: 1.6)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppColors.dangerBgSoft, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('نقاط تحتاج تطوير', style: tj(10, weight: FontWeight.w700, color: AppColors.orangeAccent)),
                                const SizedBox(height: 5),
                                Text('مهارات التواصل الشفهي والعرض التقديمي', style: tj(9, color: AppColors.dangerTextSoft, height: 1.6)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton(
                label: 'تنزيل PDF كامل',
                padding: const EdgeInsets.symmetric(vertical: 13),
                fontSize: 13,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جارِ تنزيل التقرير الكامل'))),
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
