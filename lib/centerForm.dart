import 'package:flutter/material.dart';

String? Function(String?) emailValidator = (email) => email != null &&
    RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email) ? null : 'Please enter valid email.';

String? Function(String?) pswdValidator = (pswd) => pswd != null
    && pswd.length >= 8 && pswd.contains(RegExp(r'[0-9]')) ? null
    : 'Passwords must be at least 8 characters and contain a number';

class CenterForm extends StatefulWidget {
  final GlobalKey<FormState> _formKey;
  final String title;
  final List<Widget> children;
  const CenterForm({required this.title, required formKey, required this.children, Key? key}) :
        _formKey = formKey, super(key: key);

  @override
  State<CenterForm> createState() => _CenterFormState();
}

class _CenterFormState extends State<CenterForm> {
  @override
  void initState() {
    // TODO: implement initState
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
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: 500,
            child: Form(
              key: widget._formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.children
            ),
            ),
          )
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
