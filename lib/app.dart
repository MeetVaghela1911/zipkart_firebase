import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/core/theme/AppTheme.dart';

import 'core/globle_provider/TheameMode.dart';
import 'core/routes/routes.dart';



class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final brightness = MediaQuery.platformBrightnessOf(context);

    // 🔥 SAFE: schedule AFTER build
    Future.microtask(() {
      ref.read(themeBrightnessProvider.notifier).state = brightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = ref.watch(themeBrightnessProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'zipkart_firebase',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
