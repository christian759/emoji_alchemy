import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static bool _initialized = false;
  
  static Future<void> init() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  // Interstitial Ad
  static InterstitialAd? _interstitialAd;
  static int _discoveryCount = 0;

  static void showDiscoveryAd() {
    _discoveryCount++;
    if (_discoveryCount % 5 == 0) {
      _loadInterstitial();
    }
  }

  static void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: InterstitialAd.testAdUnitId, // Use test ID for now
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd?.show();
        },
        onAdFailedToLoad: (err) {
          print('Failed to load interstitial: $err');
        },
      ),
    );
  }

  // Rewarded Ad for Hints
  static void showRewardedAd(Function onReward) {
    RewardedAd.load(
      adUnitId: RewardedAd.testAdUnitId,
      request: const AdRequest(),
      adLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show(onUserEarnedReward: (ad, reward) {
            onReward();
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load rewarded: $err');
          // In dev/test, maybe just give reward anyway if ad fails
          onReward();
        },
      ),
    );
  }
}
