import 'package:batter_status/modules/pages/battery_status_page.dart';
import 'package:batter_status/modules/services/battery_info_service.dart';
import 'package:flutter/material.dart';

import 'modules/app_module.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AppModule(
      batteryInfoService: BatteryInfoService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Battery Status',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BatteryStatusApp(),
    );
  }
}
