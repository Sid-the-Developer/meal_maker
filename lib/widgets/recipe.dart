import 'package:flutter/material.dart';
import 'package:meal_planner/widgets/review.dart';
import 'package:mysql1/mysql1.dart';
import 'multifield.dart';
import 'product.dart';
import '../globals.dart';

import 'center_form.dart';

/// file for recipe form widget
class Recipe extends StatefulWidget {
  const Recipe(
      {Key? key,
      this.editable = false,
      this.id,
      required formKey,
      required this.email})
      : _formKey = formKey,
        super(key: key);

  final bool editable;
  final GlobalKey<FormState> _formKey;
  final String email;
  final int? id;

  @override
  State<StatefulWidget> createState() => RecipeState();
}

class RecipeState extends State<Recipe> {
  // variables for form values
  final List<TextFormField> _dietTags = [];
  final List<TextFormField> _cuisines = [];
  String? _name;
  String? _instructions;

  // variables for view only recipe page
  String? _author;
  double? _rating;
  final Map<String, List> _recipeProducts = {};

  // to call save to db method
  late final ProductTable _productTable = ProductTable(
    editable: widget.editable,
    recipeIDs: widget.id != null ? [widget.id!] : [],
  );

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _parseRecipeFromID();
    }
  }

  void _parseRecipeFromID() async {
    // fill recipe fields
    Results recipes = await db.query(
        'SELECT RecipeName, Name, Instructions, AVG(Rating) '
        'FROM RECIPE NATURAL JOIN USER JOIN REVIEW '
        'ON RECIPE.RecipeID = REVIEW.RecipeID'
        'WHERE RecipeID = ?',
        [widget.id]);
    for (var recipe in recipes) {
      _name = recipe[0];
      _author = recipe[1];
      _instructions = recipe[2];
      _rating = recipe[3];
    }

    // fill multifields
    Results dbDietTags = await db.query(
        'SELECT DietTag '
        'FROM DIET_TAG NATURAL JOIN RECIPE '
        'WHERE RecipeID = ?',
        [widget.id]);
    for (var dbDietTag in dbDietTags) {
      _dietTags.add(viewDietTagField(dbDietTag[0]));
    }

    Results dbCuisines = await db.query(
        'SELECT Cuisine '
        'FROM CUISINE NATURAL JOIN RECIPE '
        'WHERE RecipeID = ?',
        [widget.id]);
    for (var dbCuisine in dbCuisines) {
      _cuisines.add(viewCuisineField(dbCuisine[0]));
    }
  }

  Future<bool> _save() async {
    if (widget._formKey.currentState?.validate() ?? false) {
      widget._formKey.currentState?.save();
      // returns auto incremented recipe id
      int id = (await db.query(
              'INSERT INTO RECIPE (Email, RecipeName, Instructions) '
              'VALUES (?, ?, ?)',
              [widget.email, _name, _instructions]))
          .insertId!;

      // maps diet tags to list of tuples (id, diettagtext)
      await db.queryMulti(
          'INSERT INTO DIET_TAG (RecipeID, DietTag) VALUES (?, ?)',
          _dietTags.map<List>((tag) => [id, tag.controller!.text]).toList());
      await db.queryMulti(
          'INSERT INTO CUISINE (RecipeID, Cuisine) VALUES (?, ?)',
          _cuisines
              .map<List>((cuisine) => [id, cuisine.controller!.text])
              .toList());
      _productTable.addToDB(id);

      widget._formKey.currentState?.reset();

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$_name added successfully')));
      }
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
            title: widget.editable ? 'Write Recipe' : _name,
            children: [
              Visibility(
                  visible: !widget.editable,
                  child: InkWell(
                      child: Text(
                        'Avg Rating: $_rating/5.0',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ReviewTable(
                                recipeName: _name,
                                recipeID: widget.id!,
                                chef: widget.editable,
                                email: widget.email,
                              ),
                            ),
                          ))),
              SizedBox(
                width: 400,
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: widget.editable ? 'Name' : 'Author'),
                  initialValue: _author,
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
                      child: _productTable,
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
