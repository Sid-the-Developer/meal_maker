import 'package:flutter/material.dart';
import '../globals.dart';
import 'package:mysql1/mysql1.dart';

import '../widgets/center_form.dart';

class NewAcctPage extends StatefulWidget {
  const NewAcctPage({Key? key}) : super(key: key);

  @override
  State<NewAcctPage> createState() => _NewAcctPageState();
}

class _NewAcctPageState extends State<NewAcctPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _pswd;
  String? _name;
  String? _address;

  Future<bool> _save() async {
    // TODO: Implement sql query
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      await db.query('INSERT INTO USER VALUES (?, ?, ?, ?)',
          [_email, _name, _pswd, _address]);

      if (mounted) Navigator.of(context).pop();

      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text('Create Account'),
          centerTitle: true,
        ),
        body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Container(
                padding: const EdgeInsets.all(8.0),
                width: 500,
                child: CenterForm(
                  formKey: _formKey,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email *'),
                      validator: emailValidator,
                      onSaved: (value) {
                        _email = value;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Password *'),
                      validator: pswdValidator,
                      obscureText: true,
                      onSaved: (value) {
                        _pswd = value;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name *'),
                      validator: nullValidator,
                      onSaved: (value) {
                        _name = value;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Address *'),
                      validator: nullValidator,
                      onSaved: (value) {
                        _address = value;
                      },
                      onFieldSubmitted: (value) => _save(),
                      textInputAction: TextInputAction.next,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ElevatedButton(
                          onPressed: _save,
                          child: const Text('Create Account')),
                    ),
                  ],
                ))));
  }
}
