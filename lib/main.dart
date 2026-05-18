import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/core/theme_controller.dart';
import 'package:wasfa_sha3beya/core/services/ad_helper.dart';
import 'package:wasfa_sha3beya/features/favorites/controllers/favorites_controller.dart';
import 'package:wasfa_sha3beya/features/main_layout/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.init(
    testDeviceId: 'A26A8C348CBB9DE55788A327C8460A0E',
  );
  Get.put(FavoritesController());
  final themeCtrl = Get.put(ThemeController());
  await themeCtrl.loadTheme();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeCtrl = Get.find();
    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'وصفات مصرية',
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
      ],
      theme: themeCtrl.currentTheme,
      home: const MainLayout(),
    ));
  }
}
