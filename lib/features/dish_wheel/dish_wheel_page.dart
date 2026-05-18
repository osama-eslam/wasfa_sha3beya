import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/core/app_constants.dart';
import 'package:wasfa_sha3beya/core/services/image_service.dart';
import 'package:wasfa_sha3beya/features/dish_wheel/controllers/dish_wheel_controller.dart';
import 'package:wasfa_sha3beya/features/dish_wheel/dish_spin_wheel_page.dart';

class DishWheelPage extends StatelessWidget {
  const DishWheelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DishWheelController ctrl = Get.put(DishWheelController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("مين يغسل المواعين؟"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.dishBackgroundImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.shadow.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AddPersonBox(ctrl: ctrl, theme: theme),
                        const SizedBox(height: 20),
                        Obx(
                          () => GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: ctrl.people.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 15,
                                  crossAxisSpacing: 15,
                                  childAspectRatio: 0.85,
                                ),
                            itemBuilder: (context, index) =>
                                _PersonCard(ctrl: ctrl, index: index, theme: theme),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _SpinButton(ctrl: ctrl, theme: theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPersonBox extends StatelessWidget {
  final DishWheelController ctrl;
  final ThemeData theme;
  const _AddPersonBox({required this.ctrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: ctrl.nameController,
            decoration: const InputDecoration(
              hintText: "اكتب اسم الشخص",
            ),
          ),
          const SizedBox(height: 15),
          _IconSelector(ctrl: ctrl, theme: theme),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ctrl.addPerson(ctrl.nameController.text),
              child: const Text("اضافة شخص"),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconSelector extends StatelessWidget {
  final DishWheelController ctrl;
  final ThemeData theme;
  const _IconSelector({required this.ctrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: DishWheelController.iconPaths.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final selected = ctrl.selectedIcon.value == index;
            return GestureDetector(
              onTap: () => ctrl.selectIcon(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.outline,
                    width: 2.2,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: ImageService.assetImage(
                  DishWheelController.iconPaths[index],
                  width: 42,
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final DishWheelController ctrl;
  final int index;
  final ThemeData theme;
  const _PersonCard({required this.ctrl, required this.index, required this.theme});

  @override
  Widget build(BuildContext context) {
    final person = ctrl.people[index];
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: AssetImage(
              DishWheelController.iconPaths[person.iconIndex],
            ),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 12),
          Text(
            person.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          IconButton(
            icon: Icon(Icons.delete, color: theme.colorScheme.error, size: 28),
            onPressed: () => ctrl.removePerson(index),
          ),
        ],
      ),
    );
  }
}

class _SpinButton extends StatelessWidget {
  final DishWheelController ctrl;
  final ThemeData theme;
  const _SpinButton({required this.ctrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (ctrl.people.isEmpty) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DishSpinWheelPage(people: ctrl.people.toList()),
            ),
          );
        },
        icon: const Icon(Icons.casino_rounded),
        label: const Text("لف العجلة"),
      ),
    );
  }
}
