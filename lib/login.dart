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

  @override
  void initState() {
    // TODO: implement sql initState
    super.initState();
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
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password *'),
                obscureText: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                child: ElevatedButton(onPressed: () {
                  // TODO: Implement sql query checking
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const OverviewPage()));
                }, child: const Text('Login')),
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
