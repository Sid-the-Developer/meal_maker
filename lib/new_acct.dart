import 'package:flutter/material.dart';
import 'package:meal_planner/login.dart';
import 'package:meal_planner/overview.dart';
import 'package:mysql1/mysql1.dart';

import 'centerForm.dart';

class NewAcctPage extends StatefulWidget {
  const NewAcctPage({Key? key}) : super(key: key);

  @override
  State<NewAcctPage> createState() => _NewAcctPageState();
}

class _NewAcctPageState extends State<NewAcctPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return CenterForm(title: 'Create Account', formKey: _formKey, children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email *'),
                  validator: emailValidator,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password *'),
                  validator: pswdValidator,
                  obscureText: true,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (text) => text != null ? null : 'Required',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Address *'),
                  validator: (text) => text != null ? null : 'Required',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: ElevatedButton(onPressed: () {
                    // TODO: Implement sql query
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const OverviewPage()));
                  }, child: const Text('Create')),
                ),
              ],);
  }
}
