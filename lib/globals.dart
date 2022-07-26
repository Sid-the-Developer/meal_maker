import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/widgets/product.dart';
import 'package:mysql1/mysql1.dart';

/// file for global variables that can be imported in other files

// initialize product list
List<String> allProducts = [];
DateFormat formatter = DateFormat('yyyy-MM-dd');

Future<void> getProducts() async {
  allProducts = [
    ...(await db.query('SELECT ProductName '
            'FROM PRODUCT'))
        .map((row) => row[0])
  ];
}

// text form validators
String? Function(String?) emailValidator = (email) => email != null &&
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(email)
    ? null
    : 'Please enter valid email.';

String? Function(String?) pswdValidator = (pswd) =>
    pswd != null && pswd.length >= 8 && pswd.contains(RegExp(r'[0-9]'))
        ? null
        : 'Passwords must be at least 8 characters and contain a number';

String? Function(String?) nullValidator =
    (text) => text != null && text != '' ? null : 'Field cannot be empty';

// multifield individual units
TextFormField dietTagField({void Function(String)? onSubmit}) => TextFormField(
      controller: TextEditingController(),
      decoration: const InputDecoration(labelText: 'Diet Tag'),
      validator: nullValidator,
      onFieldSubmitted: onSubmit,
      textInputAction: TextInputAction.next,
    );

TextFormField cuisineField({void Function(String)? onSubmit}) => TextFormField(
      controller: TextEditingController(),
      decoration: const InputDecoration(labelText: 'Cuisine'),
      validator: nullValidator,
      onFieldSubmitted: onSubmit,
      textInputAction: TextInputAction.next,
    );

TextFormField typeField({void Function(String)? onSubmit}) => TextFormField(
      controller: TextEditingController(),
      decoration: const InputDecoration(labelText: 'Type'),
      validator: nullValidator,
      onFieldSubmitted: onSubmit,
      textInputAction: TextInputAction.next,
    );

// not editable
TextFormField viewDietTagField(String text) => TextFormField(
      controller: TextEditingController(text: text),
      decoration: const InputDecoration(labelText: 'Diet Tag'),
      validator: nullValidator,
      enabled: false,
      textInputAction: TextInputAction.next,
    );

TextFormField viewCuisineField(String text) => TextFormField(
  controller: TextEditingController(text: text),
      decoration: const InputDecoration(labelText: 'Cuisine'),
      validator: nullValidator,
      enabled: false,
      textInputAction: TextInputAction.next,
    );

TextFormField viewTypeField(String text) => TextFormField(
  controller: TextEditingController(),
      decoration: const InputDecoration(labelText: 'Type'),
      validator: nullValidator,
      enabled: false,
      textInputAction: TextInputAction.next,
    );

// add a product to the database needed on multiple screens
Future<bool?> addProduct(BuildContext context) async => await showDialog<bool>(
    context: context, builder: (context) => const ProductDialog());

// mysql package variables
late ConnectionSettings settings;
late MySqlConnection db;

// allows for use of column names instead of indices to reference values
List<Map<String, dynamic>> dbResultToMap(
    Results results, List<String> columns) {
  assert(results.fields.length == columns.length);
  List<Map<String, dynamic>> maps = [];

  for (var result in results) {
    Map<String, dynamic> map = {};

    for (int i = 0; i < columns.length; i++) {
      map[columns[i]] = result[i];
    }
    maps.add(map);
  }

  return maps;
}
