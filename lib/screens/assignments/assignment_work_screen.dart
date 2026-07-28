import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';

/// Dispatches to the quiz / essay / puzzle work UI (design screens 13/14/15)
/// based on the assignment's [AssignmentKind] — each is a distinct layout
/// in the source design, not variants of one screen.
class AssignmentWorkScreen extends StatelessWidget {
  final String assignmentId;
  const AssignmentWorkScreen({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    final assignment = context.read<AppState>().assignments.firstWhere((a) => a.id == assignmentId);
    return switch (assignment.kind) {
      AssignmentKind.quiz => _QuizWork(assignment: assignment),
      AssignmentKind.essay => _EssayWork(assignment: assignment),
      AssignmentKind.puzzle => _PuzzleWork(assignment: assignment),
    };
  }
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
  final Assignment assignment;
  const _QuizWork({required this.assignment});

  @override
  State<_QuizWork> createState() => _QuizWorkState();
}

class _QuizWorkState extends State<_QuizWork> {
  static const _questions = [
    ('ما ناتج جمع 7/12 + 5/12؟', ['١', '1/2', '12/24', '7/5'], 0),
  ];
  int _index = 2; // "السؤال 3 من 10" per design
  int? _selected = 0;
  Timer? _timer;
  int _seconds = 14 * 60 + 52;

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

  void _next() {
    if (_index >= 9) {
      context.go('/assignment/${widget.assignment.id}/result');
      return;
    }
    setState(() {
      _index++;
      _selected = null;
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
                        Text('السؤال ${_index + 1} من 10', style: tj(11, weight: FontWeight.w600, color: AppColors.textFaint)),
                        Text('★★☆', style: tj(12, color: AppColors.warning)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ProgressTrack(value: (_index + 1) / 10),
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
                    onTap: _index > 0 ? () => setState(() => _index--) : null,
                    child: Text('السابق', style: tj(12, weight: FontWeight.w600, color: _index > 0 ? AppColors.textFaint : AppColors.border)),
                  ),
                  Text('✓ تم الحفظ', style: tj(10, color: AppColors.success)),
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                      child: Text('التالي', style: tj(12, weight: FontWeight.w700, color: Colors.white)),
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
  final Assignment assignment;
  const _EssayWork({required this.assignment});

  @override
  State<_EssayWork> createState() => _EssayWorkState();
}

class _EssayWorkState extends State<_EssayWork> {
  final _controller = TextEditingController(
    text: 'في هذا المشروع قمت بدراسة تأثير الضوء على نمو النباتات، حيث لاحظت أن...',
  );
  Timer? _timer;
  int _seconds = 18 * 60 + 20;

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
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرفاق الملف'))),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFC7C4EF), width: 1.5),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.attach_file, size: 14, color: AppColors.textFaint),
                            const SizedBox(width: 6),
                            Text('إرفاق ملف PDF / Word', style: tj(11, color: AppColors.textFaint)),
                          ],
                        ),
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
                    child: OutlineButton(
                      label: 'معاينة',
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      fontSize: 12,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('معاينة التقرير'))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: 'تسليم',
                      shadow: false,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      fontSize: 12,
                      onTap: () => context.go('/assignment/${widget.assignment.id}/result'),
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
  final Assignment assignment;
  const _PuzzleWork({required this.assignment});

  @override
  State<_PuzzleWork> createState() => _PuzzleWorkState();
}

class _PuzzleWorkState extends State<_PuzzleWork> {
  int? _selected = 0;
  Timer? _timer;
  int _seconds = 8 * 60 + 41;

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
                    child: OutlineButton(
                      label: '💡 تلميح',
                      color: AppColors.textMuted,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      fontSize: 12,
                      onTap: () => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('لاحظ نمط الدوران والتحول بين الأشكال'))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: 'تسليم',
                      shadow: false,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      fontSize: 12,
                      onTap: () => context.go('/assignment/${widget.assignment.id}/result'),
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
