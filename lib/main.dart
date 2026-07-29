import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'state/app_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AlefApp());
}

/// The design is a single-column phone layout (390px baseline). Rather than
/// stretching every screen edge-to-edge on a tablet — which would leave text
/// and cards floating awkwardly wide — this caps the whole app at a
/// comfortable phone-ish width and centers it, in both portrait and
/// landscape, on any screen wider than that. Below the cap (real phones)
/// this is a no-op.
const double _maxAppWidth = 480;

class AlefApp extends StatelessWidget {
  const AlefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Builder(
        builder: (context) {
          final router = buildAppRouter(context.read<AppState>());
          return MaterialApp.router(
            title: 'ألف المستقبل',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            routerConfig: router,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: ColoredBox(
                  color: AppColors.scaffold,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _maxAppWidth),
                      child: Container(
                        decoration: const BoxDecoration(boxShadow: [
                          BoxShadow(color: Color(0x1A05045E), blurRadius: 40, offset: Offset(0, 12)),
                        ]),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
