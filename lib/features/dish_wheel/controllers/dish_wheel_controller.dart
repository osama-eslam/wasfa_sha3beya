import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/data/models/dish_person.dart';
import 'package:wasfa_sha3beya/data/repositories/dish_repository.dart';

class DishWheelController extends GetxController {
  final people = <DishPerson>[].obs;
  final selectedIcon = 0.obs;
  final nameController = TextEditingController();

  static const List<String> iconPaths = [
    'assets/images/icon1.png',
    'assets/images/icon2.png',
    'assets/images/icon3.png',
    'assets/images/icon4.png',
    'assets/images/icon5.png',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    final loaded = await DishRepository.loadPeople();
    people.assignAll(loaded);
  }

  Future<void> _savePeople() async {
    await DishRepository.savePeople(people);
  }

  bool _nameExists(String name) {
    return people.any(
      (p) => p.name.trim().toLowerCase() == name.trim().toLowerCase(),
    );
  }

  void addPerson(String name) {
    if (name.trim().isEmpty) return;
    if (_nameExists(name)) {
      Get.snackbar('', 'الاسم موجود بالفعل ❌',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
      return;
    }
    people.add(DishPerson(name: name.trim(), iconIndex: selectedIcon.value));
    _savePeople();
    nameController.clear();
  }

  void removePerson(int index) {
    people.removeAt(index);
    _savePeople();
  }

  void selectIcon(int index) {
    selectedIcon.value = index;
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
