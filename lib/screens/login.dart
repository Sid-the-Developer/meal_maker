import 'package:flutter/material.dart';
import 'package:meal_planner/screens/new_acct.dart';
import '../widgets/center_form.dart';
import 'package:mysql1/mysql1.dart';

import 'overview.dart';
import '../globals.dart';

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
    super.initState();
    initDB();
  }

  void initDB() async {
    // init mysql local connection
    settings = ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'root',
        password: '4400',
        db: 'meal_planner');
    db = await MySqlConnection.connect(settings);
  }

  Future<bool> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      Results results = await db.query(
          'select exists(select * from USER where Email = ? and Pswd = ?)',
          [_email, _pswd]);
      bool valid = results.first.first == 1; // 1: true, 0: false

      if (!mounted) return false;

      if (valid) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OverviewPage(
                  email: _email,
                )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Incorrect email and password combo'),
          backgroundColor: Colors.red,
        ));
      }
      return valid;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text('Meal Maker'),
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
                  title: 'Login',
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email *'),
                      validator: emailValidator,
                      onSaved: (value) {
                        _email = value!.toLowerCase();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Password *'),
                      obscureText: true,
                      validator: nullValidator,
                      textInputAction: TextInputAction.next,
                      onSaved: (value) {
                        _pswd = value!;
                      },
                      onFieldSubmitted: (value) => _login(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ElevatedButton(
                          onPressed: _login, child: const Text('Login')),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NewAcctPage())),
                      child: const Text(
                        'Don' 't have an account? Click Here',
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    )
                  ], // This trailing comma makes auto-formatting nicer for build methods.
                ))));
  }
}
