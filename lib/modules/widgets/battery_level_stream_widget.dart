import 'package:batter_status/modules/app_module.dart';
import 'package:flutter/material.dart';

class BatteryLevelStreamWidget extends StatelessWidget {
  const BatteryLevelStreamWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: AppModule.of(context)!.batteryInfoService.batteryLevelStream,
      initialData: AppModule.of(context)!.batteryInfoService.batteryLevel,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          return Text('Battery level: ${snapshot.data}%');
        } else {
          return const Text('Battery level not available');
        }
      },
    );
  }
}
