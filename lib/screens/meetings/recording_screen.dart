import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  static const _speeds = [1.0, 1.25, 1.5, 2.0];
  int _speedIndex = 0;
  bool _loading = true;
  String? _error;
  ApiRecording? _recording;
  VideoPlayerController? _player;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final recording = await MeetingsApi.instance.recording(widget.meetingId);
      if (recording == null) {
        if (mounted) setState(() { _loading = false; _error = 'لا يوجد تسجيل متاح لهذا اللقاء بعد'; });
        return;
      }
      final player = VideoPlayerController.networkUrl(Uri.parse(recording.playbackUrl));
      await player.initialize();
      player.addListener(_playerChanged);
      if (!mounted) {
        await player.dispose();
        return;
      }
      setState(() { _recording = recording; _player = player; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'تعذر تحميل التسجيل'; });
    }
  }

  void _playerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _togglePlayback() async {
    final player = _player;
    if (player == null) return;
    player.value.isPlaying ? await player.pause() : await player.play();
  }

  Future<void> _changeSpeed() async {
    _speedIndex = (_speedIndex + 1) % _speeds.length;
    await _player?.setPlaybackSpeed(_speeds[_speedIndex]);
    if (mounted) setState(() {});
  }

  Future<void> _seekBy(Duration delta) async {
    final player = _player;
    if (player == null) return;
    final target = player.value.position + delta;
    await player.seekTo(target < Duration.zero ? Duration.zero : target);
  }

  @override
  void dispose() {
    _player?.removeListener(_playerChanged);
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (_error != null || _recording == null || _player == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: StateMessage(icon: Text('!', style: tj(40, color: AppColors.coral)), iconBg: AppColors.dangerBg, title: _error ?? 'لا يوجد تسجيل', subtitle: '')),
      );
    }

    final recording = _recording!;
    final player = _player!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: player.value.aspectRatio == 0 ? 16 / 9 : player.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(player),
                  GestureDetector(
                    onTap: _togglePlayback,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
                      child: Icon(player.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    ),
                  ),
                  const Positioned(top: 14, left: 14, child: _ProtectedBadge()),
                  Positioned(left: 0, right: 0, bottom: 0, child: VideoProgressIndicator(player, allowScrubbing: true, colors: const VideoProgressColors(playedColor: AppColors.primary))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recording.title, style: tj(16, weight: FontWeight.w800, color: AppColors.textHeading)),
                    const SizedBox(height: 6),
                    Text('${recording.views} مشاهدة', style: tj(11, color: AppColors.textFaint)),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: AppColors.screenBg, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(onPressed: () => _seekBy(const Duration(seconds: -10)), icon: const Icon(Icons.replay_10, color: AppColors.textMuted)),
                          IconButton(onPressed: _togglePlayback, icon: Icon(player.value.isPlaying ? Icons.pause_circle : Icons.play_circle, color: AppColors.primary, size: 32)),
                          IconButton(onPressed: () => _seekBy(const Duration(seconds: 10)), icon: const Icon(Icons.forward_10, color: AppColors.textMuted)),
                          TextButton(onPressed: _changeSpeed, child: Text('${_speeds[_speedIndex]}x', style: tj(11, weight: FontWeight.w700, color: AppColors.primary))),
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

class _ProtectedBadge extends StatelessWidget {
  const _ProtectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const AppIcon(IconBodies.lock, size: 11, color: Colors.white, strokeWidth: 2),
        const SizedBox(width: 5),
        Text('محمي', style: tj(11, color: Colors.white)),
      ]),
    );
  }
}
