import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wasfa_sha3beya/core/app_constants.dart';
import 'package:wasfa_sha3beya/core/services/ad_helper.dart';
import 'package:wasfa_sha3beya/core/widgets/banner_ad_widget.dart';
import 'package:wasfa_sha3beya/data/models/dish_person.dart';
import 'package:wasfa_sha3beya/features/dish_wheel/widgets/wheel_painter.dart';

class DishSpinWheelPage extends StatefulWidget {
  final List<DishPerson> people;
  const DishSpinWheelPage({super.key, required this.people});

  @override
  State<DishSpinWheelPage> createState() => _DishSpinWheelPageState();
}

class _DishSpinWheelPageState extends State<DishSpinWheelPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _angle = 0;
  bool _spinning = false;
  DishPerson? selectedPerson;
  final Random random = Random();
  List<ui.Image> loadedImages = [];
  final AudioPlayer player = AudioPlayer();
  bool _cardShown = false;

  static const List<String> jokesList = [
    "يلا يا عم يا غسيل المواعين مستنياك 😆",
    "هو انت فاكر المواعين هتغسل نفسها؟ 😂",
    "يا معلم، المطبخ بيناديك 🍽️",
    "يلا شد حيلك قبل ما المواعين تزعل منك 😜",
    "ده انت هتسيب الصحون لحد بكرة ولا إيه؟ 🤣",
    "المطبخ عامل فيها حفلة ومستنياك 🎉",
    "يا باشا الدور عليك، المواعين واقفة بتتفرج 😎",
    "يا عم الليلة عليك، خليك جامد واغسل 🧼",
    "مستنيينك يا زعيم قبل العشاء 🍴",
    "يا نجم، المواعين مش هتروح لوحدها 🌟",
  ];

  static const List<String> soundsList = ["disappointment.mp3"];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _loadImages();
    AdService.instance.isRewardedAdReady.addListener(_onAdStateChanged);
    AdService.instance.isRewardedAdLoading.addListener(_onAdStateChanged);
  }

  @override
  void dispose() {
    AdService.instance.isRewardedAdReady.removeListener(_onAdStateChanged);
    AdService.instance.isRewardedAdLoading.removeListener(_onAdStateChanged);
    _controller.stop();
    _controller.dispose();
    player.dispose();
    super.dispose();
  }

  void _onAdStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadImages() async {
    loadedImages = [];
    for (final person in widget.people) {
      try {
        final data = await rootBundle.load(
          'assets/images/icon${person.iconIndex + 1}.png',
        );
        final bytes = data.buffer.asUint8List();
        final img = await decodeImageFromList(bytes);
        loadedImages.add(img);
      } catch (_) {}
    }
    if (mounted) setState(() {});
  }

  int get _freeSpins => AdService.instance.freeDishSpins.value;

  bool get _canSpin =>
      _freeSpins > 0 && !_spinning && loadedImages.length == widget.people.length;

  Future<void> spin() async {
    if (!_canSpin) {
      if (_freeSpins <= 0) _showWatchAdDialog();
      return;
    }
    await AdService.useOneDishSpin();
    if (!mounted) return;

    setState(() {
      _spinning = true;
      selectedPerson = null;
      _cardShown = false;
    });
    if (!mounted) return;

    final spinAmount = random.nextDouble() * 2 * pi + 12 * pi;
    final animation = Tween<double>(
      begin: _angle,
      end: _angle + spinAmount,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    animation.addListener(() {
      if (mounted) setState(() => _angle = animation.value);
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) _showResult();
    });

    _controller.reset();
    _controller.forward();
  }

  void _showWatchAdDialog() {
    if (AdService.instance.isRewardedAdReady.value) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('انتهت المحاولات المجانية'),
          content: const Text('شاهد فيديو للحصول على 3 محاولات إضافية'),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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
    AdService.addDishBonus();
    AdService.instance.retryLoad();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هدية: +3 محاولات إضافية! 🎁'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _watchAdForSpins() {
    AdService.instance.showRewardedAd(
      onRewarded: () {
        AdService.addDishBonus();
      },
      onNotReady: () {
        AdService.instance.retryLoad();
      },
    );
  }

  void _showResult() async {
    if (_cardShown || widget.people.isEmpty) return;
    final segments = widget.people.length;
    final segmentAngle = 2 * pi / segments;
    final pointerAngle = _angle % (2 * pi);
    final index = ((segments - (pointerAngle / segmentAngle)) % segments).floor();
    selectedPerson = widget.people[index];
    _cardShown = true;
    if (mounted) setState(() => _spinning = false);

    try {
      final sound = soundsList[random.nextInt(soundsList.length)];
      await player.play(AssetSource('images/$sound'));
    } catch (_) {}

    final joke = jokesList[random.nextInt(jokesList.length)];
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white.withValues(alpha: 0.25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                      'assets/images/icon${selectedPerson!.iconIndex + 1}.png',
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    selectedPerson!.name,
                    style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    joke,
                    style: const TextStyle(fontSize: 20, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.withValues(alpha: 0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("تمام", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.85;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Image.asset(AppConstants.dishBackgroundImage, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const BannerAdWidget(),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.withValues(alpha: 0.85),
                        Colors.cyan.withValues(alpha: 0.85),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        "عجلة الحظ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
                const Spacer(),
                loadedImages.length == widget.people.length
                    ? Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 20,
                              offset: Offset(4, 4),
                            ),
                          ],
                          shape: BoxShape.circle,
                        ),
                        child: Transform.rotate(
                          angle: _angle,
                          child: CustomPaint(
                            size: Size(size, size),
                            painter: DishWheelPainter(
                              widget.people, loadedImages, selectedPerson,
                            ),
                          ),
                        ),
                      )
                    : const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  'المحاولات المتبقية: $_freeSpins',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: spin,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60, vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.cyanAccent],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      _spinning ? "بتلف..." : "اعرف مين",
                      style: const TextStyle(
                        fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
