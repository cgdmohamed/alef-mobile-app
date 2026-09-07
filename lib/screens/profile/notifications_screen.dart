import 'package:flutter/material.dart';
import '../../services/notifications_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/misc.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _unreadOnly = false;
  bool _loading = true;
  String? _error;
  List<ApiNotification> _all = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await NotificationsApi.instance.list();
      if (!mounted) return;
      setState(() {
        _all = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل الإشعارات';
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    await NotificationsApi.instance.markAllRead();
    setState(() {
      for (final n in _all) {
        n.read = true;
      }
    });
  }

  Future<void> _markRead(ApiNotification n) async {
    if (n.read) return;
    setState(() => n.read = true);
    await NotificationsApi.instance.markRead(n.id);
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _all.where((n) => !n.read).length;
    final visible = _unreadOnly ? _all.where((n) => !n.read).toList() : _all;

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإشعارات', style: tj(20, weight: FontWeight.w800, color: AppColors.textHeading)),
                      GestureDetector(
                        onTap: _markAllRead,
                        child: Text('تعيين الكل كمقروء', style: tj(11, weight: FontWeight.w500, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _unreadOnly = false),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          margin: const EdgeInsetsDirectional.only(end: 16),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: !_unreadOnly ? AppColors.primary : Colors.transparent, width: 2))),
                          child: Text('الكل', style: tj(12, weight: !_unreadOnly ? FontWeight.w700 : FontWeight.w400, color: !_unreadOnly ? AppColors.primary : AppColors.textFaint)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _unreadOnly = true),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _unreadOnly ? AppColors.primary : Colors.transparent, width: 2))),
                          child: Text('غير مقروءة ($unreadCount)', style: tj(12, weight: _unreadOnly ? FontWeight.w700 : FontWeight.w400, color: _unreadOnly ? AppColors.primary : AppColors.textFaint)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const _NotificationsLoading()
                  : _error != null
                      ? StateMessage(
                          icon: Text('!', style: tj(40, color: AppColors.coral)),
                          iconBg: AppColors.dangerBg,
                          title: 'تعذر تحميل الإشعارات',
                          subtitle: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
                          actionLabel: 'إعادة المحاولة',
                          onAction: _load,
                        )
                      : visible.isEmpty
                          ? const _NotificationsEmpty()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                              itemCount: visible.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, i) => _NotificationRow(notification: visible[i], onTap: () => _markRead(visible[i])),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final ApiNotification notification;
  final VoidCallback onTap;
  const _NotificationRow({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : AppColors.notifUnreadBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: const AppIcon(IconBodies.bell, size: 15, color: Colors.white, strokeWidth: 1.8),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: tj(11, weight: FontWeight.w700, color: AppColors.textBody)),
                  Text(notification.subtitle, style: tj(10, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text('${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}', style: tj(9, color: AppColors.textDisabled)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsLoading extends StatelessWidget {
  const _NotificationsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          Skeleton(height: 64, radius: 12),
          SizedBox(height: 10),
          Skeleton(height: 64, radius: 12),
          SizedBox(height: 10),
          Skeleton(height: 64, radius: 12),
          SizedBox(height: 10),
          Skeleton(height: 64, radius: 12),
        ],
      ),
    );
  }
}

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty();

  @override
  Widget build(BuildContext context) {
    return const StateMessage(
      icon: AppIcon(IconBodies.bell, size: 32, color: AppColors.primary, strokeWidth: 1.6),
      iconBg: AppColors.inputFill,
      title: 'لا إشعارات بعد',
      subtitle: 'ستظهر هنا إشعارات اللقاءات والواجبات والإنجازات',
    );
  }
}
