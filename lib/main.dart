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
      create: (_) => AppState()..bootstrap(),
      child: Builder(
        builder: (context) {
          final router = buildAppRouter(context.watch<AppState>());
          return MaterialApp.router(
            title: 'ألف المستقبل',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            routerConfig: router,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: _ResponsiveScaler(child: child ?? const SizedBox.shrink()),
              );
            },
          );
        },
      ),
    );
  }
}

/// The design is a single-column 390px-wide phone layout. On a tablet we
/// don't want to shrink it small-and-centered with empty space on the
/// sides — we want it to grow and fill the extra room instead, the way a
/// native iPad app reads noticeably larger than its iPhone counterpart.
///
/// This lays the whole app out at a "virtual" size (real size ÷ scale) and
/// then visually blows the result up by `scale` via [Transform.scale], so
/// every element — text, icons, padding, cards — grows together instead of
/// just the layout stretching while sizes stay flat. `scale` is derived
/// from how much wider the real screen is than the phone baseline, capped
/// so it plateaus into "comfortably bigger" rather than "cartoonishly
/// huge" on very large tablets. On real phones (width ~= baseline) this is
/// a no-op: scale sits at 1.0 and virtual size equals real size.
class _ResponsiveScaler extends StatelessWidget {
  final Widget child;
  const _ResponsiveScaler({required this.child});

  static const double _baseWidth = 390;
  static const double _baseHeight = 844;
  static const double _maxScale = 1.35;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Bounded by height as well as width: a landscape tablet is wide but
    // short, and scaling purely off width would shrink the *virtual* height
    // below what the phone-baseline layouts assume, overflowing them. Taking
    // the smaller of the two ratios keeps the virtual canvas at least as
    // tall as the baseline in every orientation.
    final widthScale = mq.size.width / _baseWidth;
    final heightScale = mq.size.height / _baseHeight;
    final scale = widthScale < heightScale
        ? widthScale.clamp(1.0, _maxScale)
        : heightScale.clamp(1.0, _maxScale);

    if (scale == 1.0) return child;

    final virtualSize = mq.size / scale;

    // Transform.scale alone won't do: it only repaints, it doesn't change the
    // constraints seen by descendants, so a nested SizedBox sized to the
    // (smaller) virtual dimensions gets forced back up to the real, tight
    // outer size before any scaling happens — doubling the effective scale
    // and pushing content past the screen edge. FittedBox is the primitive
    // that actually lets its child measure itself at its own natural size
    // (the virtual size, via the inner SizedBox) before scaling that result
    // to fill whatever tight box FittedBox itself was given.
    return MediaQuery(
      data: mq.copyWith(
        size: virtualSize,
        padding: mq.padding / scale,
        viewPadding: mq.viewPadding / scale,
        viewInsets: mq.viewInsets / scale,
      ),
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: virtualSize.width,
          height: virtualSize.height,
          child: child,
        ),
      ),
    );
  }
}
