import 'package:collection/collection.dart';

class Meal {
  Meal(this._meal);

  final Map<String, dynamic> _meal;

  Map<String, dynamic> get mealMap => _meal;

  @override
  bool operator ==(Object other) {
    return other is Meal
        ? const DeepCollectionEquality().equals(_meal, other._meal)
        : false;
  }

  @override
  int get hashCode => _meal.hashCode;

  @override
  String toString() {
    return _meal.toString();
  }
}
