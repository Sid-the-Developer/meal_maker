import 'package:flutter/material.dart';
/// file for global variables that can be imported in other files

// text form validators
String? Function(String?) emailValidator = (email) => email != null &&
    RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email) ? null : 'Please enter valid email.';

String? Function(String?) pswdValidator = (pswd) => pswd != null
    && pswd.length >= 8 && pswd.contains(RegExp(r'[0-9]')) ? null
    : 'Passwords must be at least 8 characters and contain a number';

String? Function(String?) nullValidator = (text) => text != null && text  != '' ? null
    : 'Field cannot be empty';

// multifield individual units
final TextFormField dietTagField = TextFormField(
  decoration: const InputDecoration(labelText: 'Diet Tag'),
  validator: nullValidator,
  textInputAction: TextInputAction.next,
);
final TextFormField cuisineField = TextFormField(
  decoration: const InputDecoration(labelText: 'Cuisine'),
  validator: nullValidator,
  textInputAction: TextInputAction.next,
);
final TextFormField typeField = TextFormField(
  decoration: const InputDecoration(labelText: 'Type'),
  validator: nullValidator,
  textInputAction: TextInputAction.next,
);