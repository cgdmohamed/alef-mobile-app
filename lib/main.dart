import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AlefApp());
}

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
            title: 'منصة ألف',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            routerConfig: router,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
