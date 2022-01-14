import 'dart:async';
import 'package:flutter/foundation.dart';

class IntervalNotifier extends ChangeNotifier {
  final VoidCallback? callAtIntervals;
  final bool notify;
  final Duration interval;
  late Timer _timer;

  IntervalNotifier({
    required this.interval,
    this.callAtIntervals,
    this.notify = true,
  }) {
    _timer = Timer.periodic(
      interval,
      (timer) {
        if (callAtIntervals != null) callAtIntervals!();
        if (notify) notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
