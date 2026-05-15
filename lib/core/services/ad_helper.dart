import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton that manages the rewarded‑ad lifecycle.
///
/// ============================================================
///  PRODUCTION MODE
/// ============================================================
/// Uses the production AdMob ad unit IDs from the dashboard.
/// The current device is registered via [testDeviceId] so
/// AdMob returns test creative — no real impressions are billed.
///
/// ============================================================
///  RELEASE BUILD
/// ============================================================
/// Remove the [testDeviceId] argument from `init()` in `main()`.
class AdService {
  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------
  static final AdService _instance = AdService._();
  factory AdService() => _instance;
  AdService._();

  static AdService get instance => _instance;

  /// Must be called once from [main].
  ///
  /// Awaits [MobileAds.instance.initialize], registers [testDeviceId]
  /// as a test device, loads spin counters, then preloads the rewarded ad.
  static Future<void> init({String? testDeviceId}) async {
    print('━━━ AdService.init ━━━');
    try {
      await MobileAds.instance.initialize();
      print('✅ AdService: MobileAds initialized');
    } catch (e) {
      print('❌ AdService: MobileAds.initialize threw: $e');
    }

    if (testDeviceId != null) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [testDeviceId]),
      );
      print('📱 AdService: Test device registered: $testDeviceId');
    }

    await _instance._loadSpinCounts();
    _instance._preloadRewardedAd();
  }

  // ---------------------------------------------------------------------------
  // Production Ad Unit IDs (from AdMob dashboard)
  // ---------------------------------------------------------------------------
  static const String _bannerAdUnitId =
      'ca-app-pub-7122533733437182/4032203790';
  static const String _rewardedAdUnitId =
      'ca-app-pub-7122533733437182/4443267337';

  static String get bannerAdUnitId => _bannerAdUnitId;

  // ---------------------------------------------------------------------------
  // Reactive state
  // ---------------------------------------------------------------------------
  final isRewardedAdReady = ValueNotifier<bool>(false);
  final isRewardedAdLoading = ValueNotifier<bool>(false);
  final isRewardedAdTimedOut = ValueNotifier<bool>(false);
  final adStatusMessage = ValueNotifier<String?>(null);
  String? lastAdError;

  /// Reactive spin counters — pages can listen or use [value] directly.
  final freeEatSpins = ValueNotifier<int>(_initialFreeSpins);
  final freeDishSpins = ValueNotifier<int>(_initialFreeSpins);

  Timer? _timeoutTimer;
  // AdMob sometimes takes up to 60s to respond (see latency in logs).
  // The timeout must be longer than that so we don't fire before the
  // server replies. 90s gives a safe 30s buffer.
  static const Duration _timeoutDuration = Duration(seconds: 90);

  // ---------------------------------------------------------------------------
  // Spin counters (SharedPreferences)
  // ---------------------------------------------------------------------------
  static const String _keyFreeEat = 'spin_free_eat';
  static const String _keyFreeDish = 'spin_free_dish';
  static const int _initialFreeSpins = 3;
  static const int _rewardedSpinBonus = 3;

  Future<void> _loadSpinCounts() async {
    freeEatSpins.value = await _getCount(_keyFreeEat);
    freeDishSpins.value = await _getCount(_keyFreeDish);
  }

  static Future<int> _getCount(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? _initialFreeSpins;
  }

  static Future<void> _setCount(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<int> useOneEatSpin() => _useOne(_keyFreeEat);
  static Future<int> useOneDishSpin() => _useOne(_keyFreeDish);

  static Future<int> _useOne(String key) async {
    final current = await _getCount(key);
    final next = (current - 1).clamp(0, _initialFreeSpins + _rewardedSpinBonus);
    await _setCount(key, next);
    _updateNotifier(key, next);
    return next;
  }

  static Future<int> addEatBonus() => _addBonus(_keyFreeEat);
  static Future<int> addDishBonus() => _addBonus(_keyFreeDish);

  static Future<int> _addBonus(String key) async {
    final current = await _getCount(key);
    final next = current + _rewardedSpinBonus;
    await _setCount(key, next);
    _updateNotifier(key, next);
    return next;
  }

  static void _updateNotifier(String key, int value) {
    if (key == _keyFreeEat) {
      _instance.freeEatSpins.value = value;
    } else {
      _instance.freeDishSpins.value = value;
    }
  }

  static Future<void> resetCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFreeEat, _initialFreeSpins);
    await prefs.setInt(_keyFreeDish, _initialFreeSpins);
    _instance.freeEatSpins.value = _initialFreeSpins;
    _instance.freeDishSpins.value = _initialFreeSpins;
  }

  // ---------------------------------------------------------------------------
  // Rewarded Ad  —  Load / Show / Retry
  // ---------------------------------------------------------------------------
  RewardedAd? _rewardedAd;
  int _retryCount = 0;
  int _loadAttempts = 0;
  bool _cooldownActive = false;

  static const int _maxRetries = 5;
  static const int _cooldownMinutes = 5;

  /// Resets ALL internal state so nothing stays stuck.
  void _forceReset() {
    _cancelTimeout();
    _rewardedAd = null;
    isRewardedAdLoading.value = false;
    isRewardedAdReady.value = false;
    isRewardedAdTimedOut.value = false;
    adStatusMessage.value = null;
    _retryCount = 0;
    _loadAttempts = 0;
    _cooldownActive = false;
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void _startTimeout() {
    _cancelTimeout();
    isRewardedAdTimedOut.value = false;
    adStatusMessage.value = 'جاري تحميل الإعلان...';
    _timeoutTimer = Timer(_timeoutDuration, () {
      if (!isRewardedAdReady.value) {
        isRewardedAdTimedOut.value = true;
        isRewardedAdLoading.value = false;
        adStatusMessage.value =
            'يستغرق الإعلان وقتًا أطول من المعتاد، جارٍ إعادة المحاولة في الخلفية...';
        print(
          '⏰ AdService: Load timed out after ${_timeoutDuration.inSeconds}s'
          ' — retrying in background',
        );
      }
    });
  }

  /// Load a rewarded ad from the server.
  ///
  /// Uses [RewardedAd.load] (matches the Spin_Wheel_Reward type in
  /// the AdMob dashboard). Wraps in try-catch so a synchronous
  /// exception does NOT leave [isRewardedAdLoading] stuck at true.
  void _preloadRewardedAd() {
    if (_cooldownActive) {
      print('⏳ AdService: Skipping load — cooldown active');
      return;
    }

    if (isRewardedAdLoading.value && _loadAttempts > 0) {
      print('⚠️ AdService: Detected stuck loading state — force resetting');
      _forceReset();
    }

    isRewardedAdLoading.value = true;
    _loadAttempts++;
    _startTimeout();

    print(
      '━━━ 📡 AdService: Loading rewarded ad (attempt $_loadAttempts) ━━━',
    );

    try {
      RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _cancelTimeout();
            _rewardedAd = ad;
            _retryCount = 0;
            isRewardedAdLoading.value = false;
            isRewardedAdReady.value = true;
            isRewardedAdTimedOut.value = false;
            lastAdError = null;
            adStatusMessage.value = 'الإعلان جاهز';
            print('━━━ ✅ AdService: Rewarded ad LOADED ━━━');
          },
          onAdFailedToLoad: (error) {
            _cancelTimeout();
            _rewardedAd = null;
            isRewardedAdLoading.value = false;
            isRewardedAdReady.value = false;
            isRewardedAdTimedOut.value = false;
            _retryCount++;

            final code = error.code;
            final msg = error.message;
            lastAdError = 'code=$code msg=$msg';
            adStatusMessage.value = 'تعذر تحميل الإعلان (code=$code)';

            String errorType;
            switch (code) {
              case 0:
                errorType = 'INTERNAL_ERROR';
                break;
              case 1:
                errorType = 'INVALID_REQUEST';
                break;
              case 2:
                errorType = 'NETWORK_ERROR';
                break;
              case 3:
                errorType = 'NO_FILL';
                break;
              default:
                errorType = 'UNKNOWN';
            }

            print(
              '━━━ ❌ AdService: Rewarded ad FAILED'
              ' (retry $_retryCount/$_maxRetries) ━━━',
            );
            print('    Error code : $code ($errorType)');
            print('    Error msg  : $msg');

            if (_retryCount <= _maxRetries) {
              final delay =
                  Duration(seconds: pow(2, _retryCount).toInt());
              print('🔁 AdService: Retrying in ${delay.inSeconds}s…');
              Future.delayed(delay, _preloadRewardedAd);
            } else {
              print(
                '⏸️  AdService: Max retries reached —'
                ' cooling down for $_cooldownMinutes min',
              );
              _cooldownActive = true;
              Future.delayed(Duration(minutes: _cooldownMinutes), () {
                print('🔄 AdService: Cooldown over — restarting preload');
                _cooldownActive = false;
                _retryCount = 0;
                _loadAttempts = 0;
                _preloadRewardedAd();
              });
            }
          },
        ),
      );
    } catch (e) {
      print('❌ AdService: RewardedAd.load THREW synchronously: $e');
      _forceReset();
      Future.delayed(const Duration(seconds: 2), _preloadRewardedAd);
    }
  }

  /// Show the currently loaded rewarded ad.
  ///
  /// Rewards are ONLY emitted inside [onUserEarnedReward] —
  /// **never** if the ad fails or is skipped.
  ///
  /// If the ad isn't ready, [onNotReady] is called immediately
  /// and the caller (page) decides what to do (instant gift).
  void showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onComplete,
    VoidCallback? onNotReady,
  }) {
    final ad = _rewardedAd;
    if (ad == null) {
      print('⚠️ AdService: showRewardedAd() called but no ad ready');
      _cancelTimeout();
      isRewardedAdTimedOut.value = false;
      adStatusMessage.value = null;
      if (_cooldownActive) {
        print('♻️ AdService: Forcing early retry (was in cooldown)');
        _cooldownActive = false;
        _retryCount = 0;
        _loadAttempts = 0;
      }
      if (!isRewardedAdLoading.value) {
        _preloadRewardedAd();
      }
      onNotReady?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('━━━ 👋 AdService: Ad dismissed by user ━━━');
        ad.dispose();
        _rewardedAd = null;
        isRewardedAdReady.value = false;
        onComplete?.call();
        _retryCount = 0;
        Future.microtask(() => _preloadRewardedAd());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        lastAdError =
            'show_failed: code=${error.code} msg=${error.message}';
        print('━━━ ❌ AdService: Failed to show ad — $lastAdError ━━━');
        ad.dispose();
        _rewardedAd = null;
        isRewardedAdReady.value = false;
        onComplete?.call();
        _retryCount = 0;
        Future.microtask(() => _preloadRewardedAd());
      },
    );

    ad.show(onUserEarnedReward: (ad, reward) {
      print(
        '━━━ 🎁 AdService: REWARD EARNED —'
        ' type=${reward.type} amount=${reward.amount} ━━━',
      );
      onRewarded();
    });
  }

  /// Force a fresh load (clears cooldown).
  void retryLoad() {
    _forceReset();
    print('🔄 AdService: Manual retry requested');
    _preloadRewardedAd();
  }
}
