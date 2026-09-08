import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:no_screenshot/overlay_mode.dart';
import 'package:no_screenshot/secure_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/meetings_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';

/// Real Agora RTC integration (agora_rtc_engine package —
/// https://pub.dev/packages/agora_rtc_engine). Requires a device or
/// emulator with camera/microphone and a real AGORA_APP_ID/
/// AGORA_APP_CERTIFICATE configured on the backend — wired against the
/// package's real API surface but not exercised end-to-end on a live
/// device, so treat first real-world runs as the actual verification step.
///
/// The design's fake poll/quiz overlay had no realistic backend (Agora's
/// SDK has no in-meeting poll primitive on its own) and has been dropped
/// rather than fabricated.
class LiveMeetingScreen extends StatefulWidget {
  final String meetingId;
  const LiveMeetingScreen({super.key, required this.meetingId});

  @override
  State<LiveMeetingScreen> createState() => _LiveMeetingScreenState();
}

class _LiveMeetingScreenState extends State<LiveMeetingScreen> {
  RtcEngine? _engine;
  String _channelName = '';

  bool _connecting = true;
  String? _error;

  final Set<int> _remoteUids = {};
  bool _micOn = true;
  bool _cameraOn = true;

  Timer? _clock;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    RtcEngine? pendingEngine;
    try {
      final permissions = await [Permission.camera, Permission.microphone].request();
      if (permissions.values.any((status) => !status.isGranted)) {
        throw StateError('Camera and microphone permissions are required');
      }
      final creds = await MeetingsApi.instance.join(widget.meetingId);

      final engine = createAgoraRtcEngine();
      pendingEngine = engine;
      await engine.initialize(RtcEngineContext(appId: creds.appId));

      engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          if (!mounted) return;
          setState(() => _connecting = false);
          _clock = Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() => _seconds++);
          });
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          if (!mounted) return;
          setState(() => _remoteUids.add(remoteUid));
        },
        onUserOffline: (connection, remoteUid, reason) {
          if (!mounted) return;
          setState(() => _remoteUids.remove(remoteUid));
        },
        onError: (err, msg) {
          if (!mounted) return;
          setState(() {
            _connecting = false;
            _error = 'تعذر الاتصال باللقاء';
          });
        },
      ));

      await engine.enableVideo();
      await engine.startPreview();
      await engine.joinChannel(
        token: creds.token,
        channelId: creds.channelName,
        uid: creds.uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      if (!mounted) return;
      setState(() {
        _engine = engine;
        _channelName = creds.channelName;
      });
    } catch (_) {
      await pendingEngine?.release();
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _error = 'تعذر الاتصال باللقاء';
      });
    }
  }

  Future<void> _toggleMic() async {
    final engine = _engine;
    if (engine == null) return;
    await engine.muteLocalAudioStream(_micOn);
    if (mounted) setState(() => _micOn = !_micOn);
  }

  Future<void> _toggleCamera() async {
    final engine = _engine;
    if (engine == null) return;
    await engine.muteLocalVideoStream(_cameraOn);
    if (mounted) setState(() => _cameraOn = !_cameraOn);
  }

  Future<void> _leave() async {
    await _engine?.leaveChannel();
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _clock?.cancel();
    final engine = _engine;
    if (engine != null) {
      engine.leaveChannel();
      engine.release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SecureWidget(mode: OverlayMode.secure, child: _buildContent(context));
  }

  Widget _buildContent(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.liveBg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center, style: tj(14, color: Colors.white)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                      child: Text('رجوع', style: tj(13, weight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_connecting || _engine == null) {
      return const Scaffold(
        backgroundColor: AppColors.liveBg,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final engine = _engine!;
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
                  Expanded(child: Text('${_remoteUids.length + 1} مشارك', style: tj(12, color: AppColors.liveMuted))),
                  Text('$mm:$ss', style: tj(11, weight: FontWeight.w600, color: AppColors.liveMuted2)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppColors.liveSurface, borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: _remoteUids.isEmpty
                    ? _VideoTile(child: AgoraVideoView(controller: VideoViewController(rtcEngine: engine, canvas: const VideoCanvas(uid: 0))))
                    : GridView.count(
                        padding: const EdgeInsets.all(8),
                        crossAxisCount: (_remoteUids.length + 1) > 2 ? 2 : 1,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        children: [
                          _VideoTile(
                            label: 'أنت',
                            child: AgoraVideoView(controller: VideoViewController(rtcEngine: engine, canvas: const VideoCanvas(uid: 0))),
                          ),
                          for (final uid in _remoteUids)
                            _VideoTile(
                              child: AgoraVideoView(
                                controller: VideoViewController.remote(
                                  rtcEngine: engine,
                                  canvas: VideoCanvas(uid: uid),
                                  connection: RtcConnection(channelId: _channelName),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ControlButton(body: IconBodies.mic, active: _micOn, onTap: _toggleMic),
                  _ControlButton(body: IconBodies.camera, active: _cameraOn, onTap: _toggleCamera),
                  _ControlButton(body: IconBodies.closeX, background: AppColors.coral, onTap: _leave),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final Widget child;
  final String? label;
  const _VideoTile({required this.child, this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(color: AppColors.liveAvatarDim, borderRadius: BorderRadius.circular(10)),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
        if (label != null)
          Positioned(
            bottom: 6,
            right: 8,
            child: Text(label!, style: tj(9, weight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85))),
          ),
      ],
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: AppIcon(body, size: body == IconBodies.closeX ? 18 : 20, color: Colors.white, strokeWidth: 1.8),
      ),
    );
  }
}
