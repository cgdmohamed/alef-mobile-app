import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:no_screenshot/overlay_mode.dart';
import 'package:no_screenshot/secure_widget.dart';
import '../../services/assignments_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';

class AssignmentWorkScreen extends StatefulWidget {
  final String assignmentId;
  const AssignmentWorkScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentWorkScreen> createState() => _AssignmentWorkScreenState();
}

class _AssignmentWorkScreenState extends State<AssignmentWorkScreen> {
  final _answer = TextEditingController();
  ApiAssignment? _assignment;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final assignment = await AssignmentsApi.instance.detail(widget.assignmentId);
      if (mounted) setState(() { _assignment = assignment; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'تعذر تحميل الواجب'; });
    }
  }

  Future<void> _submit() async {
    final value = _answer.text.trim();
    if (value.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      await AssignmentsApi.instance.submit(widget.assignmentId, {'response': value});
      if (mounted) context.go('/assignment/${widget.assignmentId}/result');
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تسليم الواجب. حاول مرة أخرى')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SecureWidget(mode: OverlayMode.secure, child: _content());
  }

  Widget _content() {
    if (_loading) return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (_error != null || _assignment == null) {
      return Scaffold(backgroundColor: Colors.white, body: SafeArea(child: StateMessage(icon: Text('!', style: tj(40, color: AppColors.coral)), iconBg: AppColors.dangerBg, title: _error ?? 'تعذر تحميل الواجب', subtitle: '')));
    }

    final assignment = _assignment!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Row(children: [
                const BackChevron(),
                const SizedBox(width: 8),
                Expanded(child: Text(assignment.title, style: tj(15, weight: FontWeight.w700, color: AppColors.textHeading))),
              ]),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(assignment.instructions?.trim().isNotEmpty == true ? assignment.instructions! : 'اكتب إجابتك على الواجب بالتفصيل.', style: tj(13, color: AppColors.textMuted, height: 1.8)),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _answer,
                      minLines: 8,
                      maxLines: 16,
                      onChanged: (_) => setState(() {}),
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(hintText: 'اكتب إجابتك هنا...'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: PrimaryButton(label: _submitting ? 'جارٍ التسليم...' : 'تسليم الواجب', onTap: (_answer.text.trim().isEmpty || _submitting) ? null : _submit),
            ),
          ],
        ),
      ),
    );
  }
}
