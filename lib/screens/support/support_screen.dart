import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/support_api.dart';
import '../../state/app_state.dart';
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
  final _input = TextEditingController();
  final _scroll = ScrollController();
  String? _conversationId;
  List<ApiSupportMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final id = await SupportApi.instance.myConversationId();
      final messages = await SupportApi.instance.messages(id);
      if (!mounted) return;
      setState(() {
        _conversationId = id;
        _messages = messages;
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _conversationId == null || _sending) return;
    setState(() => _sending = true);
    _input.clear();
    try {
      final sent = await SupportApi.instance.sendMessage(_conversationId!, text);
      if (!mounted) return;
      setState(() => _messages.add(sent));
      _scrollToBottom();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر إرسال الرسالة')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
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
                      Text('سيتم الرد من فريق الدعم قريبًا', style: tj(10, color: AppColors.textFaint)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _messages.isEmpty
                      ? Center(child: Text('ابدأ محادثة مع فريق الدعم', style: tj(12, color: AppColors.textFaint)))
                      : ListView(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                          children: [
                            for (final m in _messages)
                              _Bubble(message: m, fromUser: m.senderId == context.watch<AppState>().currentUser?.id),
                          ],
                        ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
              child: Row(
                children: [
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
  final ApiSupportMessage message;
  final bool fromUser;
  const _Bubble({required this.message, required this.fromUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: fromUser ? AppColors.primary : AppColors.inputFill,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(fromUser ? 14 : 4),
            bottomRight: Radius.circular(fromUser ? 4 : 14),
          ),
        ),
        child: Text(message.text, style: tj(12, color: fromUser ? Colors.white : AppColors.textBody)),
      ),
    );
  }
}
