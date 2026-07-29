import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/misc.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final List<ChatMessage> _messages = List.of(MockData.supportSeed);
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;

  static const _quickReplies = ['كيف أعيد جدولة لقاء؟', 'مشكلة بالدخول'];
  static const _autoReplies = [
    'شكرًا لتواصلك، سيتم الرد خلال دقائق.',
    'تم تسجيل طلبك وسيقوم أحد المختصين بمراجعته.',
    'هل هناك تفاصيل إضافية تودّين مشاركتها؟',
  ];
  int _replyIndex = 0;

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text, fromUser: true));
      _input.clear();
      _typing = true;
    });
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(ChatMessage(_autoReplies[_replyIndex % _autoReplies.length]));
        _replyIndex++;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
              child: Row(
                children: [
                  const BackChevron(),
                  const SizedBox(width: 6),
                  const AvatarPlaceholder(size: 36, color: AppColors.primaryLight),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('خدمة العملاء', style: tj(13, weight: FontWeight.w700, color: AppColors.textHeading)),
                      Text('● متصل الآن', style: tj(10, color: AppColors.success)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                children: [
                  for (final m in _messages) _Bubble(message: m),
                  if (_typing)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('يكتب الآن...', style: tj(11, color: AppColors.textDisabled)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final q in _quickReplies)
                    GestureDetector(
                      onTap: () => _send(q),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(9)),
                        child: Text(q, style: tj(10, weight: FontWeight.w500, color: AppColors.primary)),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('إرفاق ملف'))),
                    child: const AppIcon(IconBodies.paperclip, size: 16, color: AppColors.textFaint, strokeWidth: 1.8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(20)),
                      child: TextField(
                        controller: _input,
                        textAlign: TextAlign.right,
                        onSubmitted: _send,
                        style: tj(11, color: AppColors.textBody),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: 'اكتب رسالتك...'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _send(_input.text),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Transform.rotate(
                        angle: -0.785,
                        child: const AppIcon(IconBodies.send, size: 15, color: Colors.white, filled: true),
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

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.fromUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.fromUser ? AppColors.primary : AppColors.inputFill,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(message.fromUser ? 14 : 4),
            bottomRight: Radius.circular(message.fromUser ? 4 : 14),
          ),
        ),
        child: Text(message.text, style: tj(12, color: message.fromUser ? Colors.white : AppColors.textBody)),
      ),
    );
  }
}
