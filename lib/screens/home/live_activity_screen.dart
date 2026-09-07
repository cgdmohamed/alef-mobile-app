import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';

/// Destination for the student home screen's "live activity now" banner —
/// a trainer-pushed timed activity. No dedicated screen exists for this in
/// the design export, so this reuses the same timed-question card pattern
/// already used for the in-meeting poll (live_meeting_screen's _PollSheet),
/// promoted from a bottom sheet to a standalone screen.
class LiveActivityScreen extends StatefulWidget {
  const LiveActivityScreen({super.key});

  @override
  State<LiveActivityScreen> createState() => _LiveActivityScreenState();
}

class _LiveActivityScreenState extends State<LiveActivityScreen> {
  static const _options = ['التحليل والتفكيك', 'الحفظ عن ظهر قلب', 'تكرار الإجابة نفسها', 'نسخ إجابة زميل'];
  int? _selected;
  Timer? _timer;
  int _seconds = 4 * 60 + 32;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submit() {
    if (_selected == null) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال إجابتك للمدرب')));
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (_seconds % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
              child: Row(
                children: [
                  const BackChevron(),
                  Expanded(
                    child: Text(
                      'بحث عن الكلمات: مفاتيح التفكير',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tj(13, weight: FontWeight.w700, color: AppColors.textHeading),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(8)),
                    child: Text('$mm:$ss', style: tj(12, weight: FontWeight.w700, color: AppColors.coral)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.mint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('نشاط مباشر — أرسله مدربك', style: tj(11, weight: FontWeight.w700, color: AppColors.mintDark)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'أي من الكلمات التالية تدل على مهارة التفكير الناقد؟',
                      style: tj(17, weight: FontWeight.w700, color: AppColors.textHeading, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < _options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = i),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              color: _selected == i ? AppColors.tint : Colors.white,
                              border: Border.all(
                                color: _selected == i ? AppColors.primary : AppColors.border,
                                width: _selected == i ? 2 : 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _options[i],
                              style: tj(13, weight: _selected == i ? FontWeight.w600 : FontWeight.w400, color: _selected == i ? AppColors.primary : AppColors.textBody),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
              child: PrimaryButton(label: 'إرسال الإجابة', shadow: false, onTap: _selected != null ? _submit : null),
            ),
          ],
        ),
      ),
    );
  }
}
