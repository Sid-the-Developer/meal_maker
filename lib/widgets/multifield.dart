import 'package:flutter/material.dart';

class MultiField extends StatefulWidget {
  MultiField(
      {Key? key,
      required this.fields,
      this.editable = false,
      required this.field})
      : super(key: key) {
    if (fields.isEmpty) fields.add(field);
  }

  final List<Widget> fields;
  final Widget field;
  final bool editable;

  @override
  State<StatefulWidget> createState() => MultiFieldState();
}

class MultiFieldState extends State<MultiField> {
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Container(
          padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      style: BorderStyle.solid, color: Colors.grey, width: 1)),
              constraints: const BoxConstraints(
                minHeight: 50,
                minWidth: 100,
                maxWidth: 300,
                maxHeight: 200,
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: GridView.count(
                  controller: ScrollController(),
                  childAspectRatio: MediaQuery.of(context).size.aspectRatio,
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 0,
                  shrinkWrap: true,
                  children: [...widget.fields],
                ),
              )),
      Visibility(
          visible: widget.editable,
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () {
                  setState(() {
                    widget.fields.add(widget.field);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () {
                  setState(() {
                    if (widget.fields.isNotEmpty) {
                      widget.fields.removeLast();
                    }
                  });
                },
              ),
            ],
          ))
    ]);
  }
}
