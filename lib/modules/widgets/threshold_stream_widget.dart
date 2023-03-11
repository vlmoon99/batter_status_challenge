import 'package:batter_status/modules/app_module.dart';
import 'package:flutter/material.dart';

class ThresholdStreamWidget extends StatelessWidget {
  const ThresholdStreamWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: AppModule.of(context)!.batteryInfoService.thresholdStream,
      initialData: AppModule.of(context)!.batteryInfoService.threshold,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Text('Battery level threshold: ${snapshot.data}%'),
              Slider(
                value: AppModule.of(context)!
                    .batteryInfoService
                    .threshold
                    .toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label:
                    '${AppModule.of(context)!.batteryInfoService.threshold}%',
                onChanged: (double value) {
                  AppModule.of(context)!
                      .batteryInfoService
                      .updateThreshold(value.toInt());
                },
              ),
            ],
          );
        } else {
          return const Text('Battery level threshold not available');
        }
      },
    );
  }
}
