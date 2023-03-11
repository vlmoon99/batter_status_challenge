import 'dart:async';
import 'dart:io' show Platform;

import 'package:batter_status/modules/app_module.dart';
import 'package:batter_status/modules/pages/stream_battery_info.dart';
import 'package:batter_status/modules/widgets/watch_button.dart';
import 'package:flutter/material.dart';

class BatteryStatusApp extends StatefulWidget {
  const BatteryStatusApp({Key? key}) : super(key: key);

  @override
  _BatteryStatusAppState createState() => _BatteryStatusAppState();
}

class _BatteryStatusAppState extends State<BatteryStatusApp> {
  int _batteryLevel = -1;
  bool get isWatchDevice => Platform.operatingSystemVersion.contains('gwear');

  Future<void> _getBatteryLevel() async {
    final int result =
        await AppModule.of(context)!.batteryInfoService.getBatteryLevel();
    setState(() {
      _batteryLevel = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isWatchDevice
          ? null
          : AppBar(
              title: const Text('Battery Status Flutter Challenge'),
            ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isWatchDevice
                ? WatchButton(
                    text: 'Check Battery',
                    onTap: () {
                      _getBatteryLevel();
                    },
                  )
                : ElevatedButton(
                    onPressed: _getBatteryLevel,
                    child: const Text('Check Battery Level'),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _batteryLevel < 0
                    ? 'Battery level\nnot available'
                    : 'Battery level\nis : $_batteryLevel%',
                style: TextStyle(
                  fontSize: isWatchDevice
                      ? MediaQuery.of(context).size.width * 0.07
                      : MediaQuery.of(context).size.width * 0.05,
                ),
              ),
            ),
            isWatchDevice
                ? WatchButton(
                    text: 'Battery Stream',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) {
                          return const StreamBatteryInfo();
                        }),
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) {
                            return const StreamBatteryInfo();
                          }),
                        );
                      },
                      child: const Text('Battery Stream'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
