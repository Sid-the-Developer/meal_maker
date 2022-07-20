import 'package:flutter/material.dart';
import 'package:meal_planner/widgets/review.dart';
import 'multifield.dart';
import 'product.dart';
import '../globals.dart';

import 'center_form.dart';

/// file for recipe form widget
class Recipe extends StatefulWidget {
  const Recipe({Key? key,
    this.chef = false,
    this.name,
    this.author,
    this.rating,
    this.id,
    this.dietTags,
    this.cuisines,
    required formKey})
      : _formKey = formKey,
        super(key: key);

  final bool chef;
  final GlobalKey<FormState> _formKey;
  final String? name;
  final String? author;
  final double? rating;
  final int? id;
  final String? dietTags;
  final String? cuisines;

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
        child: CenterForm(
            formKey: widget._formKey,
            title: widget.chef ? 'Write Recipe' : widget.name,
            children: [
              Visibility(
                  visible: !widget.chef,
                  child: InkWell(
                    child: Text(
                      'Avg Rating: ${widget.rating}/5.0',
                      style: const TextStyle(color: Colors.blue),
                    ),
                    onTap: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                      ReviewTable(recipeName: widget.name, recipeIDs: [1, 2, 3]),
                                      ),
                  ))),
              SizedBox(
                width: 400,
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: widget.chef ? 'Name' : 'Author'),
                  initialValue: widget.author,
                  textInputAction: TextInputAction.next,
                  validator: nullValidator,
                  enabled: widget.chef,
                  onSaved: (name) => _name = name,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    Column(
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          alignment: WrapAlignment.spaceEvenly,
                          runSpacing: 8,
                          runAlignment: WrapAlignment.center,
                          children: [
                            MultiField(
                                fields: _dietTags,
                                field: dietTagField,
                                editable: false),
                            MultiField(
                                fields: _cuisines,
                                field: cuisineField,
                                editable: false),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          constraints: BoxConstraints(
                              maxHeight:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height * .3,
                              maxWidth: MediaQuery
                                  .of(context)
                                  .size
                                  .width * .3),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Instructions',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),
                            ),
                            maxLines: null,
                            initialValue: _instructions,
                            textAlignVertical: TextAlignVertical.top,
                            onSaved: (instr) => _instructions = instr,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: ProductTable(
                        editable: widget.chef,
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: widget.chef,
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
