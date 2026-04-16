import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 日本語ロケールの初期化（intl パッケージ）
  await initializeDateFormatting('ja_JP', null);
  runApp(const PoliticianMonitoringApp());
}

class PoliticianMonitoringApp extends StatelessWidget {
  const PoliticianMonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '国会議員 活動モニター',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // ネイビー
          brightness: Brightness.light,
        ),
        fontFamily: 'Noto Sans JP',
      ),
      home: const HomeScreen(),
    );
  }
}
