import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wasfa_sha3beya/core/services/ad_helper.dart';

/// Self-managing anchored-adaptive banner ad widget.
///
/// Always occupies a fixed 60‑dp slot so the layout is stable.
/// Shows a subtle grey placeholder while loading, and the real
/// [AdWidget] once the ad is served.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _banner;
  bool _loaded = false;
  static const double _bannerHeight = 60;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_banner == null) _loadBanner();
  }

  Future<void> _loadBanner() async {
    try {
      final width = MediaQuery.of(context).size.width;
      final targetSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
        Orientation.portrait,
        width.toInt(),
      );

      _banner = BannerAd(
        adUnitId: AdService.bannerAdUnitId,
        size: targetSize ?? AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('BannerAdWidget: Failed — $error');
            ad.dispose();
          },
        ),
      );
      await _banner!.load();
    } catch (e) {
      debugPrint('BannerAdWidget: Exception during load — $e');
    }
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _bannerHeight,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: _loaded && _banner != null
          ? AdWidget(ad: _banner!)
          : const SizedBox.shrink(),
    );
  }
}
