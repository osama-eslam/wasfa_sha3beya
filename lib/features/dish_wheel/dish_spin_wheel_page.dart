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
import 'package:wasfa_sha3beya/data/repositories/dish_repository.dart';
import 'package:wasfa_sha3beya/features/dish_wheel/widgets/wheel_painter.dart';

class DishSpinWheelPage extends StatefulWidget {
  final List<DishPerson> people;
  const DishSpinWheelPage({super.key, required this.people});

  @override
  State<DishSpinWheelPage> createState() => _DishSpinWheelPageState();
}

class _DishSpinWheelPageState extends State<DishSpinWheelPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  double _angle = 0;
  bool _spinning = false;
  DishPerson? selectedPerson;
  final Random random = Random();
  List<ui.Image> loadedImages = [];
  final AudioPlayer player = AudioPlayer();
  bool _cardShown = false;

  final Map<String, GlobalKey> _taskKeys = {};
  final ScrollController _scrollController = ScrollController();

  String _selectedTask = 'غسيل المواعين';
  List<String> _customTasks = [];

  static const List<String> _coreTasks = [
    'غسيل المواعين',
    'كنس الشقة',
    'نزول يجيب العيش',
    'تطبيق الهدوم',
  ];

  List<String> get _allTasks => [..._coreTasks, ..._customTasks];

  static const Map<String, List<String>> homeTasksJokes = {
    'غسيل المواعين': [
      'يا {name} المواعين مستنياك من الصبح تقوم ولا إيه؟ 😆',
      'هو انت فاكر يا {name} ان المواعين هتغسل نفسها؟ 😂',
      'يا معلم {name} المطبخ بيناديك بقاله ساعة 🍽️',
      'يلا شد حيلك يا {name} قبل ما المواعين تزعل منك 😜',
      'ده انت هتسيب الصحون يا {name} لحد بكرة ولا إيه؟ 🤣',
      'المطبخ عامل فيها حفلة يا {name} ومستنيك 🎉',
      'يا باشا {name} الدور عليك والمواعين واقفة بتتفرج 😎',
      'يا عم {name} الليلة عليك خليك جامد واغسل 🧼',
      'مستنيينك يا زعيم {name} قبل العشاء 🍴',
      'يا نجم {name} المواعين مش هتروح لوحدها 🌟',
      'قم يا {name} المواعين زعلت منك ومش عايزه حد غيرك 🥘',
      'بص يا {name} كل طبق بتغسله دعوة لك 🤲',
      'يا معلم {name} المواعين واقفة تتحداك 🥊',
      'حط السماعات يا {name} وشغل اغنية واغسل 🎵',
      'يا فندم {name} من فضلك المواعين بتستجدى 🥺',
    ],
    'كنس الشقة': [
      'يا {name} الأرض بتقولك اكنسني بقى مش هينفع كدة 🧹',
      'شوف يابا {name} الشقة عاملة زي الزبالة قوم اكنسها 😷',
      'يا معلم {name} التراب عامل زحمة جوة البيت 🏠',
      'يلا يا {name} المكنسة مستنياك ساعتها تدوق النوم 😴',
      'هو انت يا {name} شايف ان الأرض نظيفة كدة؟ 🤨',
      'يا باشا {name} الفتات اللي على الأرض مش هياكل نفسه 🍫',
      'يا عم {name} شعر اختك على الأرض مش منظر كويس 💇',
      'الغبار بيزاحمك يا {name} في البيت قوم له 💨',
      'لأ يا {name} مش هتخلص كنس لحد ما البيت يلمع ✨',
      'الكنسة اللي في الصالة مستنياك يا {name} من امبارح 🕰️',
      'قوم يا بطلة {name} وورينا شطارتك في الكنس 💃',
      'الكنس يا {name} عبادة وهتاخد عليه حسنات 🤲',
      'انت فاكر يا {name} ان الخادم اللي شغال؟ لأ ده انت 😂',
      'يا معلم {name} ركنة الباب محتاجة عناية مركزة 🧐',
      'بص يا سيدي {name} مش هنام قبل ما اشوف الأرض نظيفة 🛌',
    ],
    'نزول يجيب العيش': [
      'يا {name} العيش خلص من الصبح قوم انزل 🍞',
      'هو انت مستني العيش ينزل لك يا {name} ولا إيه؟ 😂',
      'يا معلم {name} الفطار اتأخر عشانك 🥐',
      'يلا يا نجم {name} انزل العيش بقى قبل ما يسخن 🔥',
      'يا باشا {name} الناس بتفطر واحنا مستنيينك 😤',
      'قوم يا زعيم {name} الشارع مستنيك يا رياضي 🏃',
      'يا عم {name} المخبز هيقفل وانت قاعد 🥖',
      'ده انت يا {name} مستني العيش يطبخ نفسه؟ 🫓',
      'يا فندم {name} خمس دقايق بس وتجيب العيش وتيجي ⏱️',
      'يا معلم {name} ريحة العيش السخن مستنياك 🥯',
      'قوم يلا يا {name} قبل ما امك تزعق من الشباك 😱',
      'يا {name} العيش عيون علينا من الفرن 🍞',
      'انت يا {name} اسرع من كدة ومش هتتأخر 💨',
      'يا محترم {name} البس جزمة وخد الهوا 🥾',
      'المخبز يا {name} مش هيستناك قوم بقى 🏪',
    ],
    'تطبيق الهدوم': [
      'يا {name} الهدوم مصفطفة على الكرسي مستنياك 👕',
      'هو انت يا {name} مستني الهدوم تطبق نفسها؟ 😂',
      'يا معلم {name} الدولاب عايزك بسرعة 👔',
      'يلا يا نجم {name} التطبيق مش هيخلص لوحده 🧺',
      'يا باشا {name} الهدوم اللي على السرير بتستجدى 🥺',
      'بص يا سيدي {name} كل هدومك تقولك طبقني طبقني 📢',
      'قوم يا زعيم {name} ورينا شطارتك في التطبيق 💪',
      'يا عم {name} التطبيق عبادة وهتاخد عليه اجر 🤲',
      'يا معلم {name} الكواية سخنت ومستنياك 🔥',
      'يا فندم {name} الكوي مستنيك والهدوم رايقة 👗',
      'قوم يا {name} كبس على الهدوم وريح دماغك 🎯',
      'يا {name} الهدوم النتشفة مستنياك من البلكونة 🌤️',
      'كفاية لف ودوران يا {name} طبق الهدوم ونام 🛌',
      'الهدوم يا {name} اكرم منك ومستنية تطويها 🙏',
      'بص يا سيدي {name} كلمتين في التطبيق وهترتاح 🤝',
    ],
    'generic': [
      'يا {name} قامت الساعة وقومت لـ {task} 😆',
      'هو انت فاكر يا {name} ان {task} هتعمل نفسها؟ 😂',
      'يا معلم {name} الوقت يدوبك لـ {task} ⏰',
      'يلا شد حيلك يا {name} عشان {task} 🎯',
      'ده انت هتسيب {task} يا {name} لحد بكرة؟ 🤣',
      'يا باشا {name} الدور عليك في {task} 😎',
      'يا عم {name} الليلة عليك في {task} 🧼',
      'مستنيينك يا زعيم {name} عشان {task} 🎉',
      'يا نجم {name} محدش هيعملك {task} غيرك 🌟',
      'قوم يلا يا {name} {task} مستنياك 🔥',
      'يا {name} انت وحوش الـ {task} محدش ينافسك 💪',
      'بص يا سيدي {name} {task} مش هتعمل نفسها بالذمة 😤',
      'نص ساعة بس يا {name} وتبقى خلصت {task} ⏳',
      'يا معلم {name} {task} متحداك يا بطل 🥊',
      'حط السماعات يا {name} واغسل همك في {task} 🎵',
      'شوف يابا {name} أنا عارف ان {task} تقيلة بس انت قدها 💪',
      'يا معلم {name} مين قال ان {task} صعبة؟ لأ ولا حاجة 😜',
      'قوم يا نجم {name} وخلص {task} قبل المغرب 🌅',
      'لا مؤاخذة يا {name} بس {task} مش هتسرق منك حاجة 🙏',
      'يا فندم {name} الساعة بتاع {task} دقت 🕰️',
      'يلا بينا يا {name} نبدأ في {task} ونستمتع 🎊',
      'يا {name} {task} عاملة زي الحاجة الحلوة متأخرش 🍯',
      'هو انت يا {name} فاكر ان {task} سهلة؟ طب جرب 🧪',
      'بص يا سيدي {name} خلينا صريحين {task} دورك فيه 🤝',
      'يا معلم {name} الناس كلها سايباك في {task} لوحدك 🤷',
      'قوم يا {name} مين هيعمل {task} غيرك؟ طب قول مين؟ 🤨',
      'يا عم {name} بلاش لف ودوران روح لـ {task} مباشرة 🎯',
      'الدنيا جميلة يا {name} بعد ما نخلص {task} ☀️',
      'يا زعيم {name} {task} مش هتاخد منك دقيقتين 🕐',
      'انت قدها يا {name} و{task} قدامك سهلة 💯',
      'يا معلم {name} خش على {task} وريح دماغك 🧘',
      'قوم يلا يا {name} {task} مش هتسيبك 🤗',
      'يا نجم {name} {task} مستنياك على نار هادئة 🔥',
      'بص يا {name} خلينا واقعيين الوقت يجري و{task} واقف ⏩',
      'هو احنا نكدب عليك يا {name}؟ {task} مش صعبة 😉',
      'يا معلم {name} انا واثق فيك الـ {task} خلاص هتخلص 🤲',
      'خليك جامد يا {name} وطلع {task} زي الفل 🌟',
      'يا عم {name} ولا يهمك {task} سهلة اوي 🍃',
      'قوم يا فاتح {task} وحطلك اغنية 🎶',
      'يا معلم {name} الدورة جت عليك في {task} 🎪',
      'بص يا باشا {name} {task} تنتظر ابطال زيك 🏆',
      'يلا يا {name} خشها وخلينا نفتك من {task} 🚀',
      'يا نجم {name} ماتخافش من {task} كلها ١٠ دقايق ⌛',
      'خليها عليك يا {name} {task} والله خفيفة 🪶',
      'قوم يلا يا معلم {name} صباح الفل يبدا بـ {task} 🌹',
      'يا عم {name} صباحك فل يبدا بـ {task} ☕',
      'هو انت يا {name} ناوي تسيب {task} لحد المعاد؟ 🕒',
      'بص يا سيدي {name} حط راسك في {task} وهات اخرها 🏁',
      'كفاية كسل يا {name} وقوم نعمل {task} سوا 🤝',
      'يا {name} انت فنان في {task} محدش زيك 🎨',
    ],
  };

  static const List<String> soundsList = ["disappointment.mp3"];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _loadImages();
    _loadCustomTasks();
    AdService.instance.isRewardedAdReady.addListener(_onAdStateChanged);
    AdService.instance.isRewardedAdLoading.addListener(_onAdStateChanged);
  }

  @override
  void dispose() {
    AdService.instance.isRewardedAdReady.removeListener(_onAdStateChanged);
    AdService.instance.isRewardedAdLoading.removeListener(_onAdStateChanged);
    _controller.stop();
    _controller.dispose();
    _scrollController.dispose();
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

  Future<void> _loadCustomTasks() async {
    final tasks = await DishRepository.loadCustomTasks();
    if (mounted) {
      setState(() {
        _customTasks = tasks;
      });
    }
  }

  int get _freeSpins => AdService.instance.freeDishSpins.value;

  bool get _canSpin =>
      _freeSpins > 0 &&
      !_spinning &&
      loadedImages.length == widget.people.length;

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
              child: Text('لاحقاً', style: TextStyle(color: cs.secondary)),
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
    final index = ((segments - (pointerAngle / segmentAngle)) % segments)
        .floor();
    selectedPerson = widget.people[index];
    _cardShown = true;
    if (mounted) setState(() => _spinning = false);

    try {
      final sound = soundsList[random.nextInt(soundsList.length)];
      await player.play(AssetSource('images/$sound'));
    } catch (_) {}

    String joke;
    if (_coreTasks.contains(_selectedTask)) {
      final taskJokes = homeTasksJokes[_selectedTask]!;
      joke = taskJokes[random.nextInt(taskJokes.length)];
      joke = joke.replaceAll('{name}', selectedPerson!.name);
    } else {
      final genericJokes = homeTasksJokes['generic']!;
      joke = genericJokes[random.nextInt(genericJokes.length)];
      joke = joke.replaceAll('{name}', selectedPerson!.name);
      joke = joke.replaceAll('{task}', _selectedTask);
    }

    if (!mounted) return;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: cs.surface.withValues(alpha: 0.7),
                border: Border.all(
                  color: cs.secondary.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: cs.primary.withValues(alpha: 0.3),
                    backgroundImage: AssetImage(
                      'assets/images/icon${selectedPerson!.iconIndex + 1}.png',
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    selectedPerson!.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    joke,
                    style: TextStyle(fontSize: 18, color: cs.onSurface.withValues(alpha: 0.7)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
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

  void _showAddTaskSheet() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final taskController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.85),
                border: Border(
                  top: BorderSide(color: cs.secondary.withValues(alpha: 0.25)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'أضف مهمة جديدة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      controller: taskController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'اكتب اسم المهمة الجديدة',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (taskController.text.trim().isNotEmpty &&
                            !_allTasks.contains(taskController.text.trim())) {
                          _addCustomTask(taskController.text.trim());
                          Navigator.pop(ctx);
                        } else if (_allTasks.contains(taskController.text.trim())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('المهمة موجودة بالفعل'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: cs.error,
                            ),
                          );
                        }
                      },
                      child: const Text('إضافة'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) => taskController.dispose());
  }

  void _addCustomTask(String taskName) {
    final newList = [..._customTasks, taskName];
    setState(() {
      _customTasks = newList;
      _selectedTask = taskName;
    });
    DishRepository.saveCustomTasks(newList);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToTask(taskName),
    );
  }

  void _removeCustomTask(String taskName) {
    final newList = _customTasks.where((t) => t != taskName).toList();
    setState(() {
      _customTasks = newList;
      if (_selectedTask == taskName) {
        _selectedTask = _coreTasks.first;
      }
    });
    DishRepository.saveCustomTasks(newList);
  }

  GlobalKey _getTaskKey(String task) {
    if (!_taskKeys.containsKey(task)) {
      _taskKeys[task] = GlobalKey();
    }
    return _taskKeys[task]!;
  }

  void _onTaskTap(String task) {
    if (task == _selectedTask) {
      if (!_coreTasks.contains(task)) {
        _confirmRemoveCustomTask(task);
      }
      return;
    }
    setState(() => _selectedTask = task);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTask(task));
  }

  void _scrollToTask(String task) {
    final key = _getTaskKey(task);
    if (key.currentContext == null) return;
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppConstants.dishBackgroundImage, fit: BoxFit.cover),
          Container(color: cs.shadow.withValues(alpha: 0.5)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wheelSize = min(
                  constraints.maxWidth * 0.85,
                  constraints.maxHeight * 0.55,
                );
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    const BannerAdWidget(),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.55),
                            border: Border(
                              bottom: BorderSide(color: cs.secondary.withValues(alpha: 0.25)),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: cs.onSurface,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Spacer(),
                              Text(
                                "عجلة الحظ",
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(flex: 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildTaskSelector(),
                    Expanded(
                      child: Center(
                        child: loadedImages.length == widget.people.length
                            ? Container(
                                width: wheelSize,
                                height: wheelSize,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.shadow.withValues(alpha: 0.4),
                                      blurRadius: 24,
                                      offset: const Offset(0, 6),
                                    ),
                                    BoxShadow(
                                      color: cs.secondary.withValues(alpha: 0.08),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  shape: BoxShape.circle,
                                ),
                                child: Transform.rotate(
                                  angle: _angle,
                                  child: CustomPaint(
                                    size: Size(wheelSize, wheelSize),
                                    painter: DishWheelPainter(
                                      widget.people,
                                      loadedImages,
                                      selectedPerson,
                                      cs,
                                    ),
                                  ),
                                ),
                              )
                            : CircularProgressIndicator(
                                color: cs.secondary,
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'المحاولات المتبقية: $_freeSpins',
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: spin,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth < 360 ? 40 : 60,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cs.primary,
                              cs.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: cs.secondary.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          _spinning ? "بتلف..." : "اعرف مين",
                          style: TextStyle(
                            fontSize: 22,
                            color: cs.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSelector() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 56,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          controller: _scrollController,
          child: Row(
            children: [
              ..._allTasks.map((task) {
              final isSelected = task == _selectedTask;
              final isCustom = !_coreTasks.contains(task);
              return GestureDetector(
                onTap: () => _onTaskTap(task),
                child: AnimatedContainer(
                  key: _getTaskKey(task),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  constraints: const BoxConstraints(minWidth: 64),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: isCustom
                      ? const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        )
                      : const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: isSelected
                        ? cs.secondary
                        : cs.surface.withValues(alpha: 0.55),
                    border: Border.all(
                      color: isSelected
                          ? cs.secondary
                          : cs.outline.withValues(alpha: 0.4),
                      width: isSelected ? 1.5 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: cs.secondary.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      color: isSelected
                          ? cs.onSecondary
                          : cs.onSurface.withValues(alpha: 0.6),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCustom)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 6),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: isSelected
                                  ? cs.onSecondary
                                  : cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        Text(task),
                      ],
                    ),
                  ),
                ),
              );
            }),
            _buildAddTaskButton(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildAddTaskButton() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GestureDetector(
      onTap: _showAddTaskSheet,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(minWidth: 56),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: cs.surface.withValues(alpha: 0.55),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: Wrap(children: [Icon(Icons.add, color: cs.secondary, size: 20)]),
      ),
    );
  }

  void _confirmRemoveCustomTask(String taskName) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('حذف المهمة', style: TextStyle(color: cs.onSurface)),
        content: Text('هل أنت متأكد من حذف "$taskName"؟',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: TextStyle(color: cs.secondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeCustomTask(taskName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
