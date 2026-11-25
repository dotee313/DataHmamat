import 'dart:async';

import 'package:flutter/material.dart';

import 'l10n.dart';
import 'notifications.dart';
import 'pages.dart';
import 'storage.dart';
import 'theme.dart';

/// رسائل الأخطاء التي تظهر للمستخدم بدلاً من الشاشة السوداء.
abstract final class StartupDiagnostics {
  static final List<String> messages = <String>[];

  static void add(Object error, [StackTrace? stack]) {
    messages.add('$error${stack == null ? '' : '\n$stack'}');
  }

  static String get text => messages.join('\n\n');
}

void main() {
  bool started = false;

  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        StartupDiagnostics.add(details.exception, details.stack);
        FlutterError.presentError(details);
      };
      ErrorWidget.builder = (FlutterErrorDetails details) => ErrorView(
            title: 'تعذّر عرض جزء من الواجهة',
            message: details.exceptionAsString(),
            stack: details.stack?.toString(),
          );

      String? startupError;
      try {
        try {
          await Store.instance.init();
        } catch (error, stack) {
          StartupDiagnostics.add(error, stack);
          startupError = 'تعذّر تحميل البيانات والإعدادات: $error';
        }
        try {
          await Notifications.init();
        } catch (error, stack) {
          StartupDiagnostics.add(error, stack);
          startupError =
              '${startupError ?? ''}\nتعذّر تهيئة الإشعارات: $error'.trim();
        }
      } catch (error, stack) {
        StartupDiagnostics.add(error, stack);
        startupError = 'خطأ أثناء بدء التطبيق: $error';
      }

      started = true;
      runApp(DataHmamatApp(startupError: startupError));

      // الإشعارات لا تمنع ظهور الواجهة أبداً؛ تُجدول بعد تشغيل التطبيق.
      unawaited(Notifications.sync());
    },
    (Object error, StackTrace stack) {
      StartupDiagnostics.add(error, stack);
      if (!started) {
        started = true;
        runApp(DataHmamatApp(
          startupError: 'خطأ غير متوقع أثناء بدء التطبيق: $error',
        ));
      }
    },
  );
}

class DataHmamatApp extends StatefulWidget {
  const DataHmamatApp({super.key, this.startupError});

  final String? startupError;

  @override
  State<DataHmamatApp> createState() => _DataHmamatAppState();
}

class _DataHmamatAppState extends State<DataHmamatApp> {
  bool _showBanner = true;

  void _showDetails() {
    final buffer = StringBuffer();
    if (widget.startupError != null) buffer.writeln(widget.startupError);
    if (StartupDiagnostics.messages.isNotEmpty) {
      buffer.writeln(StartupDiagnostics.text);
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تفاصيل الخطأ'),
        content: SingleChildScrollView(
          child: Text(
            buffer.isEmpty ? 'لا توجد أخطاء مسجّلة.' : buffer.toString(),
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.startupError;
    final hasError = error != null || StartupDiagnostics.messages.isNotEmpty;

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
              home: Column(
                children: [
                  if (hasError && _showBanner)
                    ErrorBanner(
                      message: error ?? StartupDiagnostics.messages.first,
                      onDetails: _showDetails,
                      onClose: () => setState(() => _showBanner = false),
                    ),
                  const Expanded(child: HomePage()),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    required this.onDetails,
    required this.onClose,
  });

  final String message;
  final VoidCallback onDetails;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFB3261E),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
            TextButton(
              onPressed: onDetails,
              child: const Text('تفاصيل', style: TextStyle(color: Colors.white)),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

/// تُعرض عند فشل بناء أي عنصر، بدلاً من الشاشة السوداء أو الرمادية.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    this.stack,
  });

  final String title;
  final String message;
  final String? stack;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.navy,
        appBar: AppBar(
          backgroundColor: AppTheme.navy,
          foregroundColor: Colors.white,
          title: Text(title),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.gold, size: 44),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              if (stack != null) ...[
                const SizedBox(height: 16),
                Text(
                  stack!,
                  style: const TextStyle(
                    color: Color(0xFFA9B4C6),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
