import 'dart:async';
import 'dart:developer';

import 'package:batter_status/interfaces/disposable.dart';
import 'package:batter_status/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BatteryInfoService implements Disposable {
  final Stream<int> batteryLevelStream =
      const EventChannel('plugin/batteryEvent')
          .receiveBroadcastStream()
          .map((event) => event as int);

  StreamSubscription<int>? _batteryLevelSubscription;
  int threshold = 80;
  final StreamController<int> thresholdController =
      StreamController<int>.broadcast();
  int batteryLevel = -1;
  BatteryInfoService() {
    getBatteryLevel();
    _batteryLevelSubscription =
        batteryLevelStream.listen((batteryLevelFromPlatform) {
      batteryLevel = batteryLevelFromPlatform;
      if (batteryLevelFromPlatform < threshold) {
        _showLowBatteryAlertDialog();
      }
    });
  }

  Future<int> getBatteryLevel() async {
    try {
      final int result = await const MethodChannel('plugin/battery')
          .invokeMethod('getBatteryLevel');
      batteryLevel = result;
      return result;
    } on PlatformException catch (e) {
      log('Error getting battery level: $e');

      log('Error getting battery level: ${e.message}');
      return -1;
    } catch (e) {
      log('Error getting battery level: $e');
      return -1;
    }
  }

  Stream<int> get thresholdStream => thresholdController.stream;

  void updateThreshold(int newThreshold) {
    threshold = newThreshold;
    thresholdController.add(threshold);
  }

  @override
  void dispose() {
    _batteryLevelSubscription?.cancel();
    thresholdController.close();
  }

  void _showLowBatteryAlertDialog() {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Battery'),
        content: Text('Your battery level is getting $threshold.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
