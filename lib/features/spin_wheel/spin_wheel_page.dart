import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wasfa_sha3beya/core/app_constants.dart';
import 'package:wasfa_sha3beya/core/services/ad_helper.dart';
import 'package:wasfa_sha3beya/core/services/image_service.dart';
import 'package:wasfa_sha3beya/core/widgets/banner_ad_widget.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';
import 'package:wasfa_sha3beya/features/detail/recipe_detail_page.dart';
import 'package:wasfa_sha3beya/features/spin_wheel/controllers/spin_wheel_controller.dart';
import 'package:wasfa_sha3beya/features/spin_wheel/widgets/wheel_painter.dart';

class SpinWheelPage extends StatefulWidget {
  final List<Recipe> recipes;
  const SpinWheelPage({super.key, required this.recipes});

  @override
  State<SpinWheelPage> createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final SpinWheelController _ctrl = SpinWheelController();
  bool _isCardShown = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _ctrl.attach(_controller);
    AdService.instance.isRewardedAdReady.addListener(_onAdStateChanged);
    AdService.instance.isRewardedAdLoading.addListener(_onAdStateChanged);
  }

  @override
  void dispose() {
    AdService.instance.isRewardedAdReady.removeListener(_onAdStateChanged);
    AdService.instance.isRewardedAdLoading.removeListener(_onAdStateChanged);
    _ctrl.detach();
    _controller.dispose();
    super.dispose();
  }

  void _onAdStateChanged() {
    if (mounted) setState(() {});
  }

  int get _freeSpins => AdService.instance.freeEatSpins.value;

  bool get _canSpin => _freeSpins > 0 && !_ctrl.isSpinning;

  Future<void> _startSpin() async {
    if (!_canSpin) {
      _showWatchAdDialog();
      return;
    }
    await AdService.useOneEatSpin();
    if (!mounted) return;

    _ctrl.startSpin(() {
      if (mounted) setState(() {});
    }, () {
      if (mounted) _showResult();
    });
  }

  void _spinWithPan(double velocityX) {
    if (!_canSpin || !mounted) return;
    final velocity = velocityX / 1000;
    final randomSpin = velocity * 2 * pi + Random().nextDouble() * 4 * pi;
    _ctrl.spinWithAngle(randomSpin, () {
      if (mounted) setState(() {});
    }, () {
      if (mounted) _showResult();
    });
  }

  void _showWatchAdDialog() {
    final cs = Theme.of(context).colorScheme;
    if (AdService.instance.isRewardedAdReady.value) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cs.surface,
          title: Text('انتهت المحاولات المجانية', style: TextStyle(color: cs.onSurface)),
          content: Text('شاهد فيديو للحصول على 3 محاولات إضافية',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('لاحقاً'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _watchAdForSpins();
              },
              child: const Text('شاهد فيديو'),
            ),
          ],
        ),
      );
    } else {
      _instantGift();
    }
  }

  void _instantGift() {
    AdService.addEatBonus();
    AdService.instance.retryLoad();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هدية: +3 محاولات إضافية! 🎁'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _watchAdForSpins() {
    AdService.instance.showRewardedAd(
      onRewarded: () {
        AdService.addEatBonus();
      },
      onNotReady: () {
        AdService.instance.retryLoad();
      },
    );
  }

  void _showResult() {
    if (_isCardShown) return;
    final index = _ctrl.calculateWinnerIndex(widget.recipes.length);
    _ctrl.selectedRecipe = widget.recipes[index];
    _ctrl.isSpinning = false;
    _isCardShown = true;

    if (mounted) setState(() {});

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 60, height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "اليوم هناكل: ${_ctrl.selectedRecipe!.title} 🍴",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: ImageService.networkImage(
                          _ctrl.selectedRecipe!.imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          memCacheWidth: ImageService.detailImageWidth,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _isCardShown = false;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecipeDetailPage(recipe: _ctrl.selectedRecipe!),
                            ),
                          );
                        },
                        child: const Text("ابدأ التحضير"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _isCardShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("يا ترى هتاكل اي ؟"),
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Stack(
        children: [
          SizedBox.expand(
            child: ImageService.assetImage(
              AppConstants.backgroundImage, fit: BoxFit.cover,
            ),
          ),
          Container(color: theme.colorScheme.shadow.withValues(alpha: 0.5)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const BannerAdWidget(),
                const SizedBox(height: 10),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onPanStart: (details) {
                            if (!_canSpin) return;
                            _controller.stop();
                          },
                          onPanUpdate: (details) {
                            setState(() => _ctrl.angle += details.delta.dx / 100);
                          },
                          onPanEnd: (details) {
                            _spinWithPan(details.velocity.pixelsPerSecond.dx);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.shadow.withValues(alpha: 0.5),
                                      blurRadius: 30,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                                      blurRadius: 30,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Transform.rotate(
                                  angle: _ctrl.angle,
                                  child: CustomPaint(
                                    size: Size(size, size),
                                    painter: WheelPainter(
                                      widget.recipes,
                                      theme.colorScheme,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                child: Icon(
                                  Icons.arrow_drop_down_circle,
                                  size: 60,
                                  color: theme.colorScheme.secondary,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: theme.colorScheme.shadow.withValues(alpha: 0.5),
                                      offset: const Offset(0, 3),
                                    ),
                                    Shadow(
                                      blurRadius: 16,
                                      color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'المحاولات المتبقية: $_freeSpins',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _startSpin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            _ctrl.isSpinning ? "لف العجلة..." : "أكلة اليوم",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
