import 'package:flutter/material.dart';

import 'l10n.dart';
import 'notifications.dart';
import 'pages.dart';
import 'storage.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // تهيئة المخزن والتخزين المحلي
    await Store.instance.init();
  } catch (e) {
    debugPrint('Error initializing Store: $e');
  }

  try {
    // تهيئة الإشعارات والمزامنة بشكل آمن لتجنب الشاشة السوداء عند الفشل
    await Notifications.init();
    await Notifications.sync();
  } catch (e) {
    debugPrint('Error initializing Notifications: $e');
  }

  runApp(const DataHmamatApp());
}

class DataHmamatApp extends StatelessWidget {
  const DataHmamatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: Store.instance.themeListenable,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: Store.instance.localeListenable,
          builder: (context, locale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: S.appName,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: mode,
              locale: locale,
              home: const HomePage(),
            );
          },
        );
      },
    );
  }
}
