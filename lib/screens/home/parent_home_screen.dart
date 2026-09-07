import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/home_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/misc.dart';
import 'widgets/notification_bell.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  bool _loading = true;
  String? _error;
  ParentHomeData? _data;

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
      final data = await HomeApi.instance.parentHome();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل البيانات';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const AvatarPlaceholder(size: 42),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ولي الأمر', style: tj(15, weight: FontWeight.w700, color: AppColors.textHeading)),
                        Text('${_data?.children.length ?? 0} أبناء مسجلين', style: tj(11, color: AppColors.textFaint)),
                      ],
                    ),
                  ),
                  const NotificationBell(),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                      ? StateMessage(
                          icon: Text('!', style: tj(40, color: AppColors.coral)),
                          iconBg: AppColors.dangerBg,
                          title: 'تعذر تحميل البيانات',
                          subtitle: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
                          actionLabel: 'إعادة المحاولة',
                          onAction: _load,
                        )
                      : (_data?.children.isEmpty ?? true)
                          ? StateMessage(
                              icon: const AppIcon(IconBodies.calendar, size: 34, color: AppColors.primary, strokeWidth: 1.6),
                              iconBg: AppColors.inputFill,
                              title: 'لا يوجد أبناء مرتبطون بعد',
                              subtitle: 'أكمل موافقة ولي الأمر لربط حساب ابنك/ابنتك',
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                                children: [
                                  for (final child in _data!.children) ...[
                                    AppCard(
                                      padding: const EdgeInsets.all(16),
                                      radius: 16,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(child.name, style: tj(14, weight: FontWeight.w700, color: AppColors.textHeading)),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: StatTile(
                                                  value: '${child.average}%',
                                                  label: 'الأداء العام',
                                                  valueColor: AppColors.sky,
                                                  valueSize: 15,
                                                  labelSize: 9,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: StatTile(
                                                  value: '${child.points}',
                                                  label: 'النقاط',
                                                  valueColor: AppColors.primary,
                                                  valueSize: 15,
                                                  labelSize: 9,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () => context.push('/report/${child.id}'),
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(vertical: 9),
                                              decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(10)),
                                              alignment: Alignment.center,
                                              child: Text('عرض التقرير الكامل', style: tj(12, weight: FontWeight.w700, color: AppColors.primary)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  AppCard(
                                    radius: 16,
                                    child: Row(
                                      children: [
                                        const AvatarPlaceholder(size: 40, color: AppColors.inputFill),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('التواصل مع الدعم', style: tj(12, weight: FontWeight.w700, color: AppColors.textBody)),
                                              Text('لأي استفسار حول حساب ابنك/ابنتك', style: tj(10, color: AppColors.textFaint)),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => context.push('/support'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const AppIcon(IconBodies.chat, size: 12, color: Colors.white, strokeWidth: 1.8),
                                                const SizedBox(width: 5),
                                                Text('دردشة', style: tj(10, weight: FontWeight.w600, color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
