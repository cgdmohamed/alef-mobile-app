import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _seconds = 47;

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
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  bool get _complete => _controllers.every((c) => c.text.isNotEmpty);

  void _confirm() {
    if (!_complete) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تأكيد الرمز بنجاح')));
    context.go('/login');
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
                'تم إرسال رمز مكوّن من 6 أرقام إلى sara.ahmed@email.com',
                style: tj(13, color: AppColors.textMuted, height: 1.7),
              ),
              const SizedBox(height: 22),
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
                child: RichText(
                  text: TextSpan(
                    style: tj(12, color: AppColors.textFaint),
                    children: [
                      const TextSpan(text: 'إعادة إرسال الرمز خلال '),
                      TextSpan(text: '$mm:$ss', style: tj(12, weight: FontWeight.w700, color: AppColors.primary)),
                    ],
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
              PrimaryButton(label: 'تأكيد', shadow: false, onTap: _complete ? _confirm : null),
            ],
          ),
        ),
      ),
    );
  }
}
