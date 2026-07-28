import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';

class RecordingScreen extends StatefulWidget {
  final String meetingId;
  const RecordingScreen({super.key, required this.meetingId});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool _playing = false;
  double _progress = 0.35;
  int _speedIndex = 0;
  int _tab = 0;
  static const _speeds = ['1x', '1.25x', '1.5x', '2x'];

  static const _tabContent = [
    'في هذا اللقاء تعرّفنا على المفاهيم الأساسية للهندسة الإبداعية مع أمثلة تطبيقية. تم طرح 3 أسئلة تفاعلية خلال الجلسة.',
    'المرفقات المرتبطة بهذا اللقاء: ورقة عمل "الهندسة الإبداعية"، ونموذج التقييم الذاتي، وفيديو تكميلي قصير.',
    'الأسئلة الشائعة: كيف أحصل على شهادة حضور؟ هل يمكن مشاهدة اللقاء أكثر من مرة؟ كيف أرسل سؤالًا للمدرب لاحقًا؟',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 230,
              color: AppColors.liveSurface,
              child: Stack(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => _playing = !_playing),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 36,
                    left: 30,
                    child: Text('لمى ع. #4821 • 12:04', style: tj(9, weight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.3))),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon(IconBodies.lock, size: 11, color: Colors.white, strokeWidth: 2),
                          const SizedBox(width: 5),
                          Text('محمي', style: tj(11, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTapUp: (d) {
                        final box = context.findRenderObject() as RenderBox?;
                        if (box == null) return;
                        setState(() => _progress = (d.localPosition.dx / box.size.width).clamp(0, 1));
                      },
                      child: Container(
                        height: 4,
                        color: Colors.white.withValues(alpha: 0.2),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _progress,
                          child: Container(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أساسيات الهندسة الإبداعية', style: tj(16, weight: FontWeight.w800, color: AppColors.textHeading)),
                    const SizedBox(height: 6),
                    Text('أ. سلطان العتيبي • 20 يوليو • 312 مشاهدة', style: tj(11, color: AppColors.textFaint)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(color: AppColors.screenBg, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const AppIcon(IconBodies.rewind, size: 16, color: AppColors.textMuted, strokeWidth: 1.8),
                          GestureDetector(
                            onTap: () => setState(() => _playing = !_playing),
                            child: AppIcon(
                              _playing ? IconBodies.pauseFilled : IconBodies.playFilled,
                              size: 20,
                              color: AppColors.primary,
                              filled: true,
                              strokeWidth: 1.8,
                            ),
                          ),
                          const AppIcon(IconBodies.forward, size: 16, color: AppColors.textMuted, strokeWidth: 1.8),
                          GestureDetector(
                            onTap: () => setState(() => _speedIndex = (_speedIndex + 1) % _speeds.length),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(6)),
                              child: Text(_speeds[_speedIndex], style: tj(10, weight: FontWeight.w600, color: AppColors.textMuted)),
                            ),
                          ),
                          const AppIcon(IconBodies.fullscreen, size: 16, color: AppColors.textMuted, strokeWidth: 1.8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _ActionPill(icon: IconBodies.starFilled, label: 'مفضلة', filled: true)),
                        const SizedBox(width: 10),
                        Expanded(child: _ActionPill(icon: IconBodies.pencil, label: 'ملاحظاتي')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (var i = 0; i < 3; i++)
                          GestureDetector(
                            onTap: () => setState(() => _tab = i),
                            child: Container(
                              margin: const EdgeInsets.only(left: 16),
                              padding: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: _tab == i ? AppColors.primary : Colors.transparent, width: 2)),
                              ),
                              child: Text(
                                ['ملخص اللقاء', 'الأنشطة المرتبطة', 'الأسئلة الشائعة'][i],
                                style: tj(12, weight: _tab == i ? FontWeight.w700 : FontWeight.w400, color: _tab == i ? AppColors.primary : AppColors.textFaint),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    Text(_tabContent[_tab], style: tj(11, color: AppColors.textMuted, height: 1.8)),
                    if (_tab == 0) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(8)),
                            child: Text('الهندسة', style: tj(9, weight: FontWeight.w500, color: AppColors.primary)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(8)),
                            child: Text('الإبداع', style: tj(9, weight: FontWeight.w500, color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: AppColors.warningBgSoft, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppIcon(IconBodies.shield, size: 12, color: AppColors.warningText, strokeWidth: 1.8),
                          const SizedBox(width: 6),
                          Text('هذا المحتوى محمي بحقوق ملكية', style: tj(10, color: AppColors.warningText)),
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
    );
  }
}

class _ActionPill extends StatefulWidget {
  final String icon;
  final String label;
  final bool filled;
  const _ActionPill({required this.icon, required this.label, this.filled = false});

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  late bool _active = widget.filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _active = !_active),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(widget.icon, size: 13, color: AppColors.textMuted, filled: widget.icon == IconBodies.starFilled && _active, strokeWidth: 1.8),
            const SizedBox(width: 5),
            Text(widget.label, style: tj(11, weight: FontWeight.w600, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
