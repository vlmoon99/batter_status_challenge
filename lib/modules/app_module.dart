import 'package:batter_status/interfaces/disposable.dart';
import 'package:batter_status/modules/services/battery_info_service.dart';
import 'package:flutter/material.dart';

class AppModule extends InheritedWidget implements Disposable {
  final BatteryInfoService batteryInfoService;
  const AppModule({
    Key? key,
    required this.batteryInfoService,
    required Widget child,
  }) : super(key: key, child: child);

  static AppModule? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppModule>();
  }

  @override
  bool updateShouldNotify(AppModule oldWidget) {
    return batteryInfoService != oldWidget.batteryInfoService;
  }

  @override
  void dispose() {
    batteryInfoService.dispose();
  }
}
