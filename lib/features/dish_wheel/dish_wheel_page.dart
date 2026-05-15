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
    final DishWheelController ctrl = Get.put(DishWheelController());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal.shade800.withValues(alpha: 0.95),
        title: const Text("مين يغسل المواعين؟"),
        elevation: 6,
        shadowColor: Colors.black38,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.dishBackgroundImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _AddPersonBox(ctrl: ctrl),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(() => GridView.builder(
                    itemCount: ctrl.people.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) =>
                        _PersonCard(ctrl: ctrl, index: index),
                  )),
                ),
                const SizedBox(height: 12),
                _SpinButton(ctrl: ctrl),
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
  const _AddPersonBox({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(blurRadius: 12, color: Colors.black26, offset: Offset(0, 6)),
        ],
        border: Border.all(color: Colors.teal, width: 1.5),
      ),
      child: Column(
        children: [
          TextField(
            controller: ctrl.nameController,
            decoration: InputDecoration(
              hintText: "اكتب اسم الشخص",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.teal.shade200),
              ),
            ),
          ),
          const SizedBox(height: 15),
          _IconSelector(ctrl: ctrl),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ctrl.addPerson(ctrl.nameController.text),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadowColor: Colors.black45,
                elevation: 8,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade600, Colors.teal.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 52,
                  child: const Text(
                    "اضافة شخص",
                    style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconSelector extends StatelessWidget {
  final DishWheelController ctrl;
  const _IconSelector({required this.ctrl});

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
                    color: selected ? Colors.teal.shade700 : Colors.grey.shade300,
                    width: 2.2,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.teal.withValues(alpha: 0.35),
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
  const _PersonCard({required this.ctrl, required this.index});

  @override
  Widget build(BuildContext context) {
    final person = ctrl.people[index];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, blurRadius: 10, offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.teal, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: AssetImage(DishWheelController.iconPaths[person.iconIndex]),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            person.name,
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 28),
            onPressed: () => ctrl.removePerson(index),
          ),
        ],
      ),
    );
  }
}

class _SpinButton extends StatelessWidget {
  final DishWheelController ctrl;
  const _SpinButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (ctrl.people.isEmpty) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DishSpinWheelPage(people: ctrl.people.toList()),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.black54,
          elevation: 10,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade600, Colors.teal.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            alignment: Alignment.center,
            height: 58,
            child: const Text(
              "لف العجلة 🎡",
              style: TextStyle(
                fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
