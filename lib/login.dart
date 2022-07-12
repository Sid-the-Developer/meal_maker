import 'package:flutter/material.dart';
import 'package:meal_planner/new_acct.dart';
import 'centerForm.dart';
import 'package:mysql1/mysql1.dart';

import 'overview.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _pswd;

  @override
  void initState() {
    // TODO: implement sql initState
    super.initState();
  }

  Future<bool> _login() {
    // TODO: Implement sql query checking
    Navigator.push(context, MaterialPageRoute(builder: (context) => const OverviewPage()));
    return Future(() => true);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return CenterForm(
            formKey: _formKey,
            title: 'Login',
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email *'),
                validator: emailValidator,
                onSaved: (value) {
                  _email = value ?? '';
                },
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password *'),
                obscureText: true,
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _pswd = value ?? '';
                },
                onFieldSubmitted: (value) => _login(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                child: ElevatedButton(onPressed: _login, child: const Text('Login')),
              ),
              InkWell(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const NewAcctPage())),
                child: const Text('Don''t have an account? Click Here', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),),
              )
            ],// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
