import 'package:flutter/material.dart';
import '../../services/meetings_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/misc.dart';

class RecordingScreen extends StatefulWidget {
  final String meetingId;
  const RecordingScreen({super.key, required this.meetingId});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool _playing = false;
  double _progress = 0;
  int _speedIndex = 0;
  static const _speeds = ['1x', '1.25x', '1.5x', '2x'];

  bool _loading = true;
  String? _error;
  ApiRecording? _recording;

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
      final data = await MeetingsApi.instance.recording(widget.meetingId);
      if (!mounted) return;
      setState(() {
        _recording = data;
        _loading = false;
        if (data == null) _error = 'لا يوجد تسجيل متاح لهذا اللقاء بعد';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل التسجيل';
        _loading = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (_error != null || _recording == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: StateMessage(
            icon: Text('!', style: tj(40, color: AppColors.coral)),
            iconBg: AppColors.dangerBg,
            title: _error ?? 'لا يوجد تسجيل',
            subtitle: '',
          ),
        ),
      );
    }

    final recording = _recording!;
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
                    child: Text(
                      _formatDuration(recording.durationSeconds),
                      style: tj(9, weight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.3)),
                    ),
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
                    Text(recording.title, style: tj(16, weight: FontWeight.w800, color: AppColors.textHeading)),
                    const SizedBox(height: 6),
                    Text('${recording.views} مشاهدة', style: tj(11, color: AppColors.textFaint)),
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
