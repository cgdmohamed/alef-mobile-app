import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';

class LiveMeetingScreen extends StatefulWidget {
  final String meetingId;
  const LiveMeetingScreen({super.key, required this.meetingId});

  @override
  State<LiveMeetingScreen> createState() => _LiveMeetingScreenState();
}

class _LiveMeetingScreenState extends State<LiveMeetingScreen> {
  Timer? _clock;
  int _seconds = 12 * 60 + 4;
  bool _micOn = true;
  bool _cameraOn = true;
  bool _pollShown = false;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _seconds++));
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_pollShown) {
        _pollShown = true;
        _showPoll();
      }
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  void _showPoll() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const _PollSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (_seconds % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: AppColors.liveBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('مباشر', style: tj(12, weight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('أساسيات الهندسة الإبداعية', style: tj(12, color: AppColors.liveMuted), overflow: TextOverflow.ellipsis),
                  ),
                  Text('$mm:$ss', style: tj(11, weight: FontWeight.w600, color: AppColors.liveMuted2)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppColors.liveSurface, borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          _ParticipantThumb(color: AppColors.primary, ring: true),
                          const SizedBox(width: 6),
                          _ParticipantThumb(color: AppColors.primaryLight),
                          const SizedBox(width: 6),
                          _ParticipantThumb(color: AppColors.sky),
                          const SizedBox(width: 6),
                          _ParticipantThumb(color: AppColors.coral),
                          const SizedBox(width: 6),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: AppColors.liveAvatarDim, borderRadius: BorderRadius.circular(9)),
                            alignment: Alignment.center,
                            child: Text('+8', style: tj(9, weight: FontWeight.w600, color: AppColors.liveMuted2)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.5), shape: BoxShape.circle),
                          ),
                          Positioned(
                            top: 6,
                            right: 16,
                            child: Text('لمى ع. #4821', style: tj(9, weight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.45))),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 20,
                            child: Text('لمى ع. #4821', style: tj(9, weight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.35))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  const AppIcon(IconBodies.chat, size: 13, color: AppColors.liveMuted2, strokeWidth: 1.8),
                  const SizedBox(width: 6),
                  Expanded(child: Text('نورة: هل ممكن تعيد الشرح؟', style: tj(11, color: AppColors.liveMuted2))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ControlButton(
                    body: IconBodies.mic,
                    active: _micOn,
                    onTap: () => setState(() => _micOn = !_micOn),
                  ),
                  _ControlButton(
                    body: IconBodies.camera,
                    active: _cameraOn,
                    onTap: () => setState(() => _cameraOn = !_cameraOn),
                  ),
                  _ControlButton(body: IconBodies.arrowUp, onTap: () {}),
                  _ControlButton(body: IconBodies.chat, onTap: () {}),
                  _ControlButton(
                    body: IconBodies.closeX,
                    background: AppColors.coral,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantThumb extends StatelessWidget {
  final Color color;
  final bool ring;
  const _ParticipantThumb({required this.color, this.ring = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
        border: ring ? Border.all(color: AppColors.gold, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: AppIcon(IconBodies.person, size: 16, color: Colors.white.withValues(alpha: 0.9), strokeWidth: 1.8),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String body;
  final bool active;
  final Color? background;
  final VoidCallback onTap;
  const _ControlButton({required this.body, this.active = true, this.background, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = background ?? (active ? AppColors.liveControl : AppColors.coral.withValues(alpha: 0.85));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: AppIcon(body, size: body == IconBodies.closeX ? 16 : 18, color: Colors.white, strokeWidth: 1.8),
      ),
    );
  }
}

class _PollSheet extends StatefulWidget {
  const _PollSheet();

  @override
  State<_PollSheet> createState() => _PollSheetState();
}

class _PollSheetState extends State<_PollSheet> {
  int? _selected = 0;
  int _seconds = 15;
  Timer? _timer;

  static const _options = ['المثلث المتساوي الأضلاع', 'القوس المتساوي', 'المثلث غير المتساوي'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
        Navigator.of(context).maybePop();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('سؤال من المدرب', style: tj(13, weight: FontWeight.w700, color: AppColors.textHeading)),
              Text('$_seconds ثانية', style: tj(10, weight: FontWeight.w600, color: AppColors.textFaint)),
            ],
          ),
          const SizedBox(height: 10),
          Text('ما هو أفضل شكل هندسي لتوزيع الأحمال في الجسر؟', style: tj(13, color: AppColors.textBody)),
          const SizedBox(height: 12),
          for (var i = 0; i < _options.length; i++) ...[
            GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _selected == i ? AppColors.tint : Colors.white,
                  border: Border.all(color: _selected == i ? AppColors.primary : AppColors.border, width: _selected == i ? 1.5 : 1.5),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  _options[i],
                  style: tj(12, weight: _selected == i ? FontWeight.w600 : FontWeight.w400, color: _selected == i ? AppColors.primary : AppColors.textBody),
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text('إرسال الإجابة', style: tj(13, weight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
