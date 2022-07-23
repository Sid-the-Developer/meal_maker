import 'package:flutter/material.dart';
import 'package:meal_planner/widgets/center_form.dart';
import 'package:meal_planner/widgets/recipe.dart';

import '../globals.dart';
import '../widgets/multifield.dart';

class BrowseRecipes extends StatefulWidget {
  const BrowseRecipes({Key? key, required this.chef, required this.email})
      : super(key: key);
  final bool chef;
  final String email;

  @override
  State<StatefulWidget> createState() => BrowseRecipesState();
}

class BrowseRecipesState extends State<BrowseRecipes> {
  late List<Map<String, dynamic>> _recipes = [];
  late Map<int, List<String>> _recipeCuisines = {};
  late Map<int, List<String>> _recipeDietTags = {};
  final List<TextFormField> _dietTags = [];
  final List<TextFormField> _cuisines = [];

  bool _sortAsc = true;
  int _sortIndex = 5;
  final GlobalKey<FormState> _mealKey = GlobalKey();
  int? year;
  int? month;
  int? day;

  @override
  void initState() {
    super.initState();
    _getRecipes();
  }

  void _getRecipes() async {
    _recipes = dbResultToMap(
        await db.query(
            'SELECT REVIEW.RecipeID, TMP.RecipeName, TMP.Name, AVG(Rating) AS Avg '
            'FROM REVIEW JOIN (SELECT RecipeID, Name, RecipeName '
            'FROM USER NATURAL JOIN RECIPE) AS TMP '
            'ON REVIEW.RecipeID = TMP.RecipeID '
            'GROUP BY TMP.RecipeID'
            'ORDER BY Avg ${_sortAsc ? 'ASC' : 'DESC'}'),
        ['RecipeID', 'Name', 'Author', 'Rating']);

    var allDietTags = dbResultToMap(
        await db.query('SELECT RecipeID, DietTag FROM DIET_TAG'),
        ['RecipeID', 'Diet Tag']);
    for (var map in allDietTags) {
      if (_recipeDietTags[map['RecipeID']] != null) {
        _recipeDietTags[map['RecipeID']]?.add(map['Diet Tag']);
      } else {
        _recipeDietTags[map['RecipeID']] = [map['Diet Tag']];
      }
    }

    var allCuisines = dbResultToMap(
        await db.query('SELECT RecipeID, Cuisine FROM CUISINE'),
        ['RecipeID', 'Cuisine']);
    for (var map in allCuisines) {
      if (_recipeCuisines[map['RecipeID']] != null) {
        _recipeCuisines[map['RecipeID']]?.add(map['Cuisine']);
      } else {
        _recipeCuisines[map['RecipeID']] = [map['Cuisine']];
      }
    }
  }

  List<Map<String, dynamic>> _filter() {
    // deep copy
    List<Map<String, dynamic>> filtered =
        _recipes.map((e) => Map<String, dynamic>.of(e)).toList();
    List<int> invalidRecipeIDs = [];

    // find recipes that do not contain at least one of the filters then remove them
    for (TextFormField dietTag in _dietTags) {
      if (dietTag.controller?.text != '') {
        for (MapEntry<int, List<String>> recipe in _recipeDietTags.entries) {
          if (!recipe.value.contains(dietTag.controller?.text)) {
            invalidRecipeIDs.add(recipe.key);
          }
        }
      }
    }

    // remove invalid diettags to make cuisine loop faster
    filtered.removeWhere(
        (element) => invalidRecipeIDs.contains(element['RecipeID']));

    // do the same with cuisines
    for (TextFormField cuisine in _cuisines) {
      if (cuisine.controller?.text != '') {
        for (MapEntry<int, List<String>> recipe in _recipeCuisines.entries) {
          if (!recipe.value.contains(cuisine.controller?.text)) {
            invalidRecipeIDs.add(recipe.key);
          }
        }
      }
    }

    // remove invalid again
    filtered.removeWhere(
        (element) => invalidRecipeIDs.contains(element['RecipeID']));

    return filtered;
  }

  _save() {
    if (_mealKey.currentState?.validate() ?? false) {
      _mealKey.currentState?.save();
      // TODO sql
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Browse Recipes',
            style: TextStyle(fontSize: 25),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              MultiField(
                fields: _dietTags,
                field: dietTagField,
                editable: true,
              ),
              MultiField(
                fields: _cuisines,
                field: cuisineField,
                editable: true,
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .75),
          child: DataTable(
            showCheckboxColumn: false,
            sortAscending: _sortAsc,
            sortColumnIndex: _sortIndex,
            // border: TableBorder.all(),
            columns: [
              const DataColumn(
                  label: Center(
                    child: Text(
                      'ID',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  numeric: true),
              const DataColumn(
                label: Center(
                    child: Text(
                  'Name',
                  textAlign: TextAlign.center,
                )),
              ),
              const DataColumn(
                  label: Center(
                    child: Text(
                      'Author',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  numeric: true),
              const DataColumn(
                label: Center(
                  child: Text(
                    'Cuisines',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const DataColumn(
                label: Center(
                  child: Text(
                    'Diet Tags',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              DataColumn(
                  label: const Center(
                      child: Text(
                    'Avg Rating',
                    textAlign: TextAlign.center,
                  )),
                  numeric: true,
                  onSort: (index, asc) {
                    setState(() {
                      _sortAsc = asc;
                      _sortIndex = index;
                      _getRecipes();
                    });
                  }),
              DataColumn(
                  label: const Center(
                      child: Text(
                    '% Own',
                    textAlign: TextAlign.center,
                  )),
                  numeric: true,
                  onSort: (index, asc) {
                    setState(() {
                      _sortAsc = asc;
                      _sortIndex = index;
                      _getRecipes();
                    });
                  }),
            ],
            rows: _filter()
                .map<DataRow>((recipe) => DataRow(
                        cells: [
                          DataCell(Text('${recipe['RecipeID']}')),
                          DataCell(Text(recipe['Name'])),
                          DataCell(Text(recipe['Author'])),
                          DataCell(Text(
                              _recipeCuisines[recipe['RecipeID']]?.join(', ') ??
                                  '')),
                          DataCell(Text(
                              _recipeDietTags[recipe['RecipeID']]?.join(', ') ??
                                  '')),
                          DataCell(Text('${recipe['Rating']}')),
                          DataCell(Text(widget.chef ? ' ' : 'N/A'))
                        ],
                        onSelectChanged: (selected) {
                          if (selected ?? false) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Recipe(
                                    formKey: GlobalKey(),
                                    editable: widget.chef,
                                    id: recipe['RecipeID'],
                                    email: widget.email,
                                  ),
                                  Visibility(
                                    visible: widget.chef,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8, 16, 8, 8),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CenterForm(
                                                            title:
                                                                'Recipe - Plan Meal',
                                                            formKey: _mealKey,
                                                            children: [
                                                              SizedBox(
                                                                width: 200,
                                                                child:
                                                                    InputDatePickerFormField(
                                                                  initialDate:
                                                                      DateTime
                                                                          .now(),
                                                                  lastDate: DateTime(
                                                                      DateTime.now()
                                                                              .year +
                                                                          100),
                                                                  errorInvalidText:
                                                                      'Invalid date: must be in the future',
                                                                  errorFormatText:
                                                                      'Must be in date format',
                                                                  firstDate:
                                                                      DateTime
                                                                          .now(),
                                                                  onDateSubmitted:
                                                                      (_) =>
                                                                          _save(),
                                                                  onDateSaved:
                                                                      (date) {
                                                                    year = date
                                                                        .year;
                                                                    month = date
                                                                        .month;
                                                                    day = date
                                                                        .day;
                                                                  },
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible:
                                                                    widget.chef,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          8,
                                                                          16,
                                                                          8,
                                                                          8),
                                                                  child: ElevatedButton(
                                                                      onPressed:
                                                                          _save,
                                                                      child: const Text(
                                                                          'Save')),
                                                                ),
                                                              ),
                                                            ])));
                                          },
                                          child: const Text('Plan Meal')),
                                    ),
                                  ),
                                ],
                              ),
                            ));
                          }
                        }))
                .toList(),
          ),
        ),
      ],
    );
  }
}
