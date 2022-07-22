import 'package:flutter/material.dart';

class CenterForm extends StatefulWidget {
  final GlobalKey<FormState> _formKey;
  final List<Widget> children;
  final String? title;

  const CenterForm(
      {required formKey, required this.children, this.title, Key? key})
      : _formKey = formKey,
        super(key: key);

  @override
  State<CenterForm> createState() => _CenterFormState();
}

class _CenterFormState extends State<CenterForm> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.title != null
                ? Text(
                    widget.title!,
                    style: const TextStyle(fontSize: 24),
                  )
                : Container(),
            Form(
                key: widget._formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: widget.children)),
          ],
        ),
      ),
    );
  }
}
