/// Isolated monetization layer so AdMob can be added later without
/// rewriting gameplay. V1 ships with a no-op implementation and no ads.
abstract class MonetizationService {
  Future<void> init();
  Future<bool> showRewardedHintAd();
  bool get adsEnabled;
}

class NoOpMonetizationService implements MonetizationService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> showRewardedHintAd() async => false;

  @override
  bool get adsEnabled => false;
}

class Monetization {
  static MonetizationService instance = NoOpMonetizationService();
}
