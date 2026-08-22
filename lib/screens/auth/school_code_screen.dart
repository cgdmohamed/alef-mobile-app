import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import 'widgets/step_indicator.dart';

/// Step 1 of signup: a school-issued join code. Fully mock, matching the
/// rest of the auth flow — `ALF6A2` (case-insensitive) is the one code that
/// validates; any other complete 6-character entry shows the error state.
class SchoolCodeScreen extends StatefulWidget {
  const SchoolCodeScreen({super.key});

  @override
  State<SchoolCodeScreen> createState() => _SchoolCodeScreenState();
}

enum _CodeState { incomplete, valid, invalid }

class _SchoolCodeScreenState extends State<SchoolCodeScreen> {
  static const _validCode = 'ALF6A2';
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  _CodeState get _state {
    if (_controllers.any((c) => c.text.isEmpty)) return _CodeState.incomplete;
    return _code.toUpperCase() == _validCode ? _CodeState.valid : _CodeState.invalid;
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
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
                child: Row(
                  children: List.generate(6, (i) {
                    final filled = _controllers[i].text.isNotEmpty;
                    final invalid = state == _CodeState.invalid;
                    final borderColor = invalid
                        ? AppColors.coral
                        : filled
                            ? AppColors.primary
                            : AppColors.border;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: i == 5 ? 0 : 8),
                        child: AspectRatio(
                          aspectRatio: 0.82,
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _nodes[i],
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                              UpperCaseTextFormatter(),
                            ],
                            style: tj(20, weight: FontWeight.w800, color: AppColors.textHeading),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: AppColors.tint,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor, width: filled || invalid ? 1.5 : 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor, width: filled || invalid ? 1.5 : 1),
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
                              if (i == 5 && v.isNotEmpty) FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (state == _CodeState.valid) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    border: Border.all(color: AppColors.tintBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text('✓', style: tj(9, weight: FontWeight.w700, color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          Text('كود صحيح', style: tj(12, weight: FontWeight.w700, color: AppColors.mint)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _infoRow('المدرسة', 'مدارس الرواد الأهلية'),
                      const SizedBox(height: 6),
                      _infoRow('البرنامج', 'المفكر الناقد الصغير'),
                      const SizedBox(height: 6),
                      _infoRow('الفصل', 'السادس / أ'),
                    ],
                  ),
                ),
              ],
              if (state == _CodeState.invalid) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.dangerBgSoft,
                    border: Border.all(color: AppColors.coral.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('×', style: tj(14, weight: FontWeight.w800, color: AppColors.coral)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الكود غير صالح أو منتهي الصلاحية أو استُنفد — راجع معلمك.',
                          style: tj(11, color: AppColors.dangerTextSoft, height: 1.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'متابعة',
                onTap: state == _CodeState.valid ? () => context.push('/signup/details') : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tj(12, color: AppColors.textMuted)),
        Text(value, style: tj(12, weight: FontWeight.w700, color: AppColors.textLabel)),
      ],
    );
  }
}

/// Forces typed characters to uppercase, matching the design's `ALF6A2` style.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
