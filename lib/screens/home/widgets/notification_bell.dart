import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/app_icon.dart';

/// The bell icon + unread-count dot shown in both home dashboards' header.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<AppState>().unreadNotifications;
    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const AppIcon(IconBodies.bell, size: 18, color: AppColors.primary, strokeWidth: 1.8),
            if (unread > 0)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('$unread', style: tj(8, weight: FontWeight.w700, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
