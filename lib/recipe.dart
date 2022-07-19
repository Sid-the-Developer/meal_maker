import 'package:flutter/material.dart';
import 'multiField.dart';
import 'product.dart';
import 'globals.dart';

import 'centerForm.dart';

/// file for recipe form widget
class Recipe extends StatefulWidget {
  const Recipe({Key? key, this.editable = false, this.name, required formKey})
      : _formKey = formKey,
        super(key: key);

  final bool editable;
  final GlobalKey<FormState> _formKey;
  final String? name;

  @override
  State<StatefulWidget> createState() => RecipeState();
}

class RecipeState extends State<Recipe> {
  final List<TextFormField> _dietTags = [];
  final List<TextFormField> _cuisines = [];

  String? _name;
  String? _instructions;

  Future<bool> _save() async {
    // TODO: Implement sql query
    if (widget._formKey.currentState?.validate() ?? false) {
      widget._formKey.currentState?.save();
      widget._formKey.currentState?.reset();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$_name added successfully')));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: CenterForm(formKey: widget._formKey, title: 'Write Recipe',
            children: [
          SizedBox(
            width: 400,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              validator: nullValidator,
              enabled: widget.editable,
              onSaved: (name) => _name = name,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Column(children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    alignment: WrapAlignment.spaceEvenly,
                    runSpacing: 8,
                    runAlignment: WrapAlignment.center,
                    children: [
                      MultiField(fields: _dietTags, field: dietTagField, editable: true),
                        MultiField(fields: _cuisines, field: cuisineField, editable: true),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(right: 8),
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * .3,
                          maxWidth: MediaQuery.of(context).size.width * .3),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Instructions',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        onSaved: (instr) => _instructions = instr,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: ProductTable(
                        editable: true,
                      ),
                    ),
                    Visibility(
                        visible: widget.editable,
                          child: OutlinedButton(
                            child: const Text('Add a new product to db'),
                            onPressed: () => ProductTable.addProduct(context),
                          ),
                        )
                  ],
                )
              ],
            ),
          ),
          Visibility(
            visible: widget.editable,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: ElevatedButton(
                  onPressed: _save, child: const Text('Save')),
            ),
          ),
        ]),
      ),
    );
  }
}
