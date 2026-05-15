class DishPerson {
  final String name;
  final int iconIndex;

  DishPerson({required this.name, required this.iconIndex});

  Map<String, dynamic> toMap() {
    return {'name': name, 'iconIndex': iconIndex};
  }

  factory DishPerson.fromMap(Map<String, dynamic> map) {
    return DishPerson(name: map['name'] as String, iconIndex: map['iconIndex'] as int);
  }
}
