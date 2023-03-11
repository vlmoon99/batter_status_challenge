import 'package:batter_status/modules/widgets/battery_level_stream_widget.dart';
import 'package:batter_status/modules/widgets/threshold_stream_widget.dart';
import 'package:flutter/material.dart';

class StreamBatteryInfo extends StatefulWidget {
  const StreamBatteryInfo({Key? key}) : super(key: key);

  @override
  State<StreamBatteryInfo> createState() => _StreamBatteryInfoState();
}

class _StreamBatteryInfoState extends State<StreamBatteryInfo> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            BatteryLevelStreamWidget(),
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: ThresholdStreamWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
