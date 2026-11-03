import 'package:flutter/foundation.dart';

/// Analytics abstraction. Swap [DebugAnalyticsService] for Firebase later.
abstract class AnalyticsService {
  Future<void> logEvent(String name, [Map<String, Object?> params = const {}]);
}

class DebugAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, [Map<String, Object?> params = const {}]) async {
    if (kDebugMode) {
      debugPrint('[analytics] $name $params');
    }
  }
}

class Analytics {
  static AnalyticsService instance = DebugAnalyticsService();

  static Future<void> event(String name, [Map<String, Object?> params = const {}]) =>
      instance.logEvent(name, params);
}
