import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_api.dart';
import '../../services/api_client.dart';
import '../../services/enrollment_api.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';

enum OtpPurpose { login }

class OtpScreen extends StatefulWidget {
  final String phone;
  final OtpPurpose purpose;

  const OtpScreen({super.key, required this.phone, this.purpose = OtpPurpose.login});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _seconds = 47;
  bool _submitting = false;
  bool _resending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = 47;
    _timer?.cancel();
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
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  bool get _complete => _controllers.every((c) => c.text.isNotEmpty);

  Future<void> _resend() async {
    if (_seconds > 0 || _resending) return;
    setState(() => _resending = true);
    try {
      await AuthApi.instance.requestOtp(widget.phone);
      if (mounted) _startTimer();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _confirm() async {
    if (!_complete || _submitting) return;
    final code = _controllers.map((c) => c.text).join();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await context.read<AppState>().verifyOtp(widget.phone, code);
      await _redeemPendingEnrollmentCode();
      if (!mounted) return;
      context.go('/home');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// If this account just came from the school-code signup step, this is
  /// its first login — attempt the actual enrollment now (see
  /// EnrollmentApi's doc comment for why it can't happen any earlier).
  /// A returning user with no pending code skips this entirely.
  Future<void> _redeemPendingEnrollmentCode() async {
    final code = await EnrollmentApi.instance.takePendingCode();
    if (code == null) return;
    try {
      await EnrollmentApi.instance.redeem(code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التحقق من الكود والالتحاق بمدرستك بنجاح')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تسجيل الدخول، لكن تعذر ربطك بالمدرسة: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (_seconds % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: i == 3 ? 0 : 6),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i < 2 ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),
              Text('رمز التحقق', style: tj(24, weight: FontWeight.w800, color: AppColors.textHeading)),
              const SizedBox(height: 8),
              Text(
                'تم إرسال رمز مكوّن من 6 أرقام إلى ${widget.phone}',
                style: tj(13, color: AppColors.textMuted, height: 1.7),
              ),
              const SizedBox(height: 14),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(10)),
                  child: Text(_error!, style: tj(12, color: AppColors.coral)),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: 42,
                      height: 52,
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _nodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: tj(18, weight: FontWeight.w700, color: AppColors.textHeading),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _controllers[i].text.isNotEmpty ? AppColors.primary : AppColors.border,
                              width: _controllers[i].text.isNotEmpty ? 2 : 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _controllers[i].text.isNotEmpty ? AppColors.primary : AppColors.border,
                              width: _controllers[i].text.isNotEmpty ? 2 : 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        onChanged: (v) {
                          setState(() {});
                          if (v.isNotEmpty && i < 5) {
                            _nodes[i + 1].requestFocus();
                          } else if (v.isEmpty && i > 0) {
                            _nodes[i - 1].requestFocus();
                          }
                          if (_complete) FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 26),
              Center(
                child: _seconds > 0
                    ? RichText(
                        text: TextSpan(
                          style: tj(12, color: AppColors.textFaint),
                          children: [
                            const TextSpan(text: 'إعادة إرسال الرمز خلال '),
                            TextSpan(text: '$mm:$ss', style: tj(12, weight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: _resend,
                        child: Text(
                          _resending ? 'جارٍ إعادة الإرسال...' : 'إعادة إرسال الرمز',
                          style: tj(12, weight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
              ),
              const Spacer(),
              Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(color: AppColors.inputFill, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const AppIcon(IconBodies.lock, size: 28, color: AppColors.primary, strokeWidth: 1.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا تشارك هذا الرمز مع أي شخص لحماية حسابك',
                    textAlign: TextAlign.center,
                    style: tj(11, color: AppColors.textDisabled, height: 1.7),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: _submitting ? 'جارٍ التأكيد...' : 'تأكيد',
                shadow: false,
                onTap: (_complete && !_submitting) ? _confirm : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
