import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../services/enrollment_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import 'widgets/step_indicator.dart';

/// Step 1 of signup: a school-issued join code. It is validated atomically
/// with account creation on the next screen, so invalid codes never create
/// partial accounts.
///
/// Single free-text field rather than fixed character boxes: real codes are
/// backend-generated as `ALEF-XXXX-XXXX` (see EnrollmentCodesService), not a
/// fixed-length string that fits neatly into per-character boxes.
class SchoolCodeScreen extends StatefulWidget {
  const SchoolCodeScreen({super.key});

  @override
  State<SchoolCodeScreen> createState() => _SchoolCodeScreenState();
}

class _SchoolCodeScreenState extends State<SchoolCodeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _complete => _controller.text.trim().isNotEmpty;

  Future<void> _continue() async {
    await EnrollmentApi.instance.savePendingCode(_controller.text.trim().toUpperCase());
    if (mounted) context.push('/signup/details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepIndicator(step: 1),
              const SizedBox(height: 18),
              Text('أدخل كود مدرستك', style: tj(22, weight: FontWeight.w800, color: AppColors.textHeading)),
              const SizedBox(height: 8),
              Text(
                'الالتحاق بمنصة ألف يبدأ بكود يصدره معلمك أو إدارة المدرسة.',
                style: tj(13, color: AppColors.textMuted, height: 1.9),
              ),
              const SizedBox(height: 20),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]')),
                    UpperCaseTextFormatter(),
                  ],
                  style: tj(20, weight: FontWeight.w800, color: AppColors.textHeading),
                  decoration: InputDecoration(
                    hintText: 'ALEF-XXXX-XXXX',
                    hintStyle: tj(20, weight: FontWeight.w800, color: AppColors.textDisabled),
                    filled: true,
                    fillColor: AppColors.tint,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _complete ? AppColors.primary : AppColors.border, width: _complete ? 1.5 : 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (_complete) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    border: Border.all(color: AppColors.tintBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    'سيتم التحقق من صلاحية الكود وربطك بمدرستك عند إنشاء الحساب.',
                    style: tj(11, color: AppColors.textMuted, height: 1.7),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'متابعة',
                onTap: _complete ? _continue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Forces typed characters to uppercase, matching backend-generated codes'
/// `ALEF-XXXX-XXXX` style.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
