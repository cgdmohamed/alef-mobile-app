import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:no_screenshot/overlay_mode.dart';
import 'package:no_screenshot/secure_widget.dart';
import '../../services/assignments_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';

/// Dispatches to the quiz / essay / puzzle work UI (design screens 13/14/15)
/// based on the assignment's kind — each is a distinct layout in the source
/// design, not variants of one screen.
///
/// The backend only stores a generic `answerPayload` blob per submission —
/// there is no real question/puzzle content bank, so the quiz questions,
/// essay prompt, and puzzle shapes below stay local UI fixtures. Only the
/// final submit action is wired to the real API.
class AssignmentWorkScreen extends StatefulWidget {
  final String assignmentId;
  const AssignmentWorkScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentWorkScreen> createState() => _AssignmentWorkScreenState();
}

class _AssignmentWorkScreenState extends State<AssignmentWorkScreen> {
  ApiAssignment? _assignment;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final all = await AssignmentsApi.instance.myAssignments();
      final found = all.where((a) => a.id == widget.assignmentId).cast<ApiAssignment?>().firstWhere((a) => a != null, orElse: () => null);
      if (!mounted) return;
      setState(() {
        _assignment = found;
        _loading = false;
        if (found == null) _error = 'تعذر العثور على الواجب';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل الواجب';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecureWidget(mode: OverlayMode.secure, child: _buildContent());
  }

  Widget _buildContent() {
    if (_loading) {
      return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (_error != null || _assignment == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: StateMessage(
            icon: Text('!', style: tj(40, color: AppColors.coral)),
            iconBg: AppColors.dangerBg,
            title: _error ?? 'تعذر تحميل الواجب',
            subtitle: '',
          ),
        ),
      );
    }
    final assignment = _assignment!;
    return switch (assignment.kind) {
      'essay' => _EssayWork(assignment: assignment),
      'puzzle' => _PuzzleWork(assignment: assignment),
      _ => _QuizWork(assignment: assignment),
    };
  }
}

Future<void> _submitAndGoToResult(BuildContext context, String assignmentId, Map<String, dynamic> payload) async {
  try {
    await AssignmentsApi.instance.submit(assignmentId, payload);
  } catch (_) {
    // best-effort — still show the result screen, which will report "pending" if the submit didn't register
  }
  if (context.mounted) context.go('/assignment/$assignmentId/result');
}

class _WorkHeader extends StatelessWidget {
  final String title;
  final int seconds;
  const _WorkHeader({required this.title, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Row(
        children: [
          const BackChevron(),
          Expanded(
            child: Text(title, textAlign: TextAlign.center, style: tj(13, weight: FontWeight.w700, color: AppColors.textHeading)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(8)),
            child: Text('$mm:$ss', style: tj(12, weight: FontWeight.w700, color: AppColors.coral)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Quiz ----

class _QuizWork extends StatefulWidget {
  final ApiAssignment assignment;
  const _QuizWork({required this.assignment});

  @override
  State<_QuizWork> createState() => _QuizWorkState();
}

class _QuizWorkState extends State<_QuizWork> {
  static const _questions = [
    ('ما ناتج جمع 7/12 + 5/12؟', ['١', '1/2', '12/24', '7/5'], 0),
  ];
  int _index = 0;
  int? _selected;
  final List<int?> _answers = [null];
  Timer? _timer;
  int _seconds = 14 * 60 + 52;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _next() async {
    _answers[_index] = _selected;
    if (_index >= _questions.length - 1) {
      if (_submitting) return;
      setState(() => _submitting = true);
      await _submitAndGoToResult(context, widget.assignment.id, {'answers': _answers});
      return;
    }
    setState(() {
      _index++;
      _selected = _answers.length > _index ? _answers[_index] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[0];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _WorkHeader(title: widget.assignment.title, seconds: _seconds),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('السؤال ${_index + 1} من ${_questions.length}', style: tj(11, weight: FontWeight.w600, color: AppColors.textFaint)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ProgressTrack(value: (_index + 1) / _questions.length),
                    const SizedBox(height: 16),
                    Text(q.$1, style: tj(17, weight: FontWeight.w700, color: AppColors.textHeading, height: 1.6)),
                    const SizedBox(height: 16),
                    for (var i = 0; i < q.$2.length; i++) ...[
                      GestureDetector(
                        onTap: () => setState(() => _selected = i),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: _selected == i ? AppColors.tint : Colors.white,
                            border: Border.all(color: _selected == i ? AppColors.primary : AppColors.border, width: _selected == i ? 2 : 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            q.$2[i],
                            style: tj(13, weight: _selected == i ? FontWeight.w600 : FontWeight.w400, color: _selected == i ? AppColors.primary : AppColors.textBody),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _index > 0 ? () => setState(() { _answers[_index] = _selected; _index--; _selected = _answers[_index]; }) : null,
                    child: Text('السابق', style: tj(12, weight: FontWeight.w600, color: _index > 0 ? AppColors.textFaint : AppColors.border)),
                  ),
                  Text('✓ تم الحفظ', style: tj(10, color: AppColors.success)),
                  GestureDetector(
                    onTap: _submitting ? null : _next,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        _index >= _questions.length - 1 ? (_submitting ? 'جارٍ التسليم...' : 'إنهاء') : 'التالي',
                        style: tj(12, weight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
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

// --------------------------------------------------------------- Essay ----

class _EssayWork extends StatefulWidget {
  final ApiAssignment assignment;
  const _EssayWork({required this.assignment});

  @override
  State<_EssayWork> createState() => _EssayWorkState();
}

class _EssayWorkState extends State<_EssayWork> {
  final _controller = TextEditingController();
  Timer? _timer;
  int _seconds = 18 * 60 + 20;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) setState(() => _seconds--);
    });
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  int get _wordCount => _controller.text.trim().isEmpty ? 0 : _controller.text.trim().split(RegExp(r'\s+')).length;

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    await _submitAndGoToResult(context, widget.assignment.id, {'text': _controller.text});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _WorkHeader(title: widget.assignment.title, seconds: _seconds),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'اكتب تقريرًا عن تجربة علمية قمت بها، موضحًا الخطوات والنتائج والاستنتاج',
                      style: tj(12, color: AppColors.textMuted, height: 1.7),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: AppColors.divider, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text('B', style: tj(13, weight: FontWeight.w700, color: AppColors.textBody)),
                          const SizedBox(width: 12),
                          Text('I', style: tj(13, color: AppColors.textBody).copyWith(fontStyle: FontStyle.italic)),
                          const SizedBox(width: 12),
                          const Icon(Icons.format_list_bulleted, size: 15, color: AppColors.textBody),
                          const SizedBox(width: 12),
                          const Icon(Icons.image_outlined, size: 15, color: AppColors.textBody),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          expands: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.top,
                          style: tj(12, color: AppColors.textBody, height: 1.8),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_wordCount / 300 كلمة', style: tj(11, color: AppColors.textFaint)),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 11, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text('يُحفظ تلقائيًا', style: tj(10, color: AppColors.success)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: _submitting ? 'جارٍ التسليم...' : 'تسليم',
                      shadow: false,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      fontSize: 12,
                      onTap: _submitting ? null : _submit,
                    ),
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

// -------------------------------------------------------------- Puzzle ----

class _PuzzleWork extends StatefulWidget {
  final ApiAssignment assignment;
  const _PuzzleWork({required this.assignment});

  @override
  State<_PuzzleWork> createState() => _PuzzleWorkState();
}

class _PuzzleWorkState extends State<_PuzzleWork> {
  int? _selected;
  Timer? _timer;
  int _seconds = 8 * 60 + 41;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    await _submitAndGoToResult(context, widget.assignment.id, {'selected': _selected});
  }

  @override
  Widget build(BuildContext context) {
    final shapes = <Widget>[
      Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8))),
      Container(width: 34, height: 34, decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle)),
      Transform.rotate(angle: 0.785, child: Container(width: 34, height: 34, color: AppColors.sky)),
      CustomPaint(size: const Size(34, 30), painter: _TrianglePainter(AppColors.coral)),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _WorkHeader(title: widget.assignment.title, seconds: _seconds),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(14)),
                      alignment: Alignment.center,
                      child: Text('صورة اللغز', style: tj(12, color: AppColors.textFaint)),
                    ),
                    const SizedBox(height: 14),
                    Text('أيّ شكل يكمل التسلسل التالي؟', style: tj(14, weight: FontWeight.w700, color: AppColors.textHeading, height: 1.6)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: List.generate(shapes.length, (i) {
                          final selected = _selected == i;
                          return GestureDetector(
                            onTap: () => setState(() => _selected = i),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected ? AppColors.tint : Colors.white,
                                border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1.5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: shapes[i],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: _submitting ? 'جارٍ التسليم...' : 'تسليم',
                      shadow: false,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      fontSize: 12,
                      onTap: (_submitting || _selected == null) ? null : _submit,
                    ),
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

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => oldDelegate.color != color;
}
