import 'package:flutter/material.dart';

import 'pages.dart';
import 'storage.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.instance.init();
  runApp(const DataHmamatApp());
}

class DataHmamatApp extends StatelessWidget {
  const DataHmamatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Data Hmamat',
      theme: AppTheme.light(),
      home: const HomePage(),
    );
  }
}
