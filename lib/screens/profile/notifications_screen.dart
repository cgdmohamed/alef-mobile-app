import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/misc.dart';
import '../../widgets/section_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final all = appState.notifications;
    final unreadCount = appState.unreadNotifications;
    final visible = _unreadOnly ? all.where((n) => !n.read).toList() : all;

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
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
                        onTap: appState.markAllNotificationsRead,
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
              child: SectionState(
                section: DemoSection.notifications,
                loading: (context) => const _NotificationsLoading(),
                empty: (context) => const _NotificationsEmpty(),
                isEmpty: (context) => visible.isEmpty,
                content: (context) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _NotificationRow(notification: visible[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final AppNotification notification;
  const _NotificationRow({required this.notification});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<AppState>().markNotificationRead(notification.id),
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
              decoration: BoxDecoration(color: notification.iconColor, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: AppIcon(notification.iconBody, size: 15, color: Colors.white, strokeWidth: 1.8),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: tj(11, weight: FontWeight.w700, color: AppColors.textBody)),
                  Text(notification.subtitle, style: tj(10, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(notification.timeLabel, style: tj(9, color: AppColors.textDisabled)),
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
