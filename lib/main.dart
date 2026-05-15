import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/core/app_theme.dart';
import 'package:wasfa_sha3beya/core/services/ad_helper.dart';
import 'package:wasfa_sha3beya/features/main_layout/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Await SDK init + ad preload before the first frame
  await AdService.init(
    testDeviceId: 'A26A8C348CBB9DE55788A327C8460A0E',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'وصفات مصرية',
      theme: AppTheme.theme,
      home: const MainLayout(),
    );
  }
}
