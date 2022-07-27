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
  List<Map<String, dynamic>> _recipes = [];
  late List<Map<String, dynamic>> _filteredList = _filter();
  late final Map<int, Set<String>> _recipeCuisines = {};
  late final Map<int, Set<String>> _recipeDietTags = {};
  final List<TextFormField> _dietTags = [];
  final List<TextFormField> _cuisines = [];
  bool _sortAsc = false;
  int _sortIndex = 5;

  // plan meal
  final GlobalKey<FormState> _mealKey = GlobalKey();
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _getRecipes();
  }

  void _getRecipes() async {
    _recipes = dbResultToMap(
        await db.query(
            'SELECT TMP.RecipeID, TMP.RecipeName, TMP.Name, AVG(Rating) AS Avg '
            'FROM REVIEW RIGHT OUTER JOIN (SELECT RecipeID, Name, RecipeName '
            'FROM USER NATURAL JOIN RECIPE) AS TMP '
            'ON REVIEW.RecipeID = TMP.RecipeID '
            'GROUP BY TMP.RecipeID '
            'ORDER BY Avg ${_sortAsc ? 'ASC' : 'DESC'}'),
        ['RecipeID', 'Name', 'Author', 'Rating']);

    var allDietTags = dbResultToMap(
        await db.query('SELECT RecipeID, DietTag FROM DIET_TAG'),
        ['RecipeID', 'Diet Tag']);
    for (var map in allDietTags) {
      if (_recipeDietTags[map['RecipeID']] != null) {
        _recipeDietTags[map['RecipeID']]?.add(map['Diet Tag']);
      } else {
        _recipeDietTags[map['RecipeID']] = {map['Diet Tag']};
      }
    }

    var allCuisines = dbResultToMap(
        await db.query('SELECT RecipeID, Cuisine FROM CUISINE'),
        ['RecipeID', 'Cuisine']);
    for (var map in allCuisines) {
      if (_recipeCuisines[map['RecipeID']] != null) {
        _recipeCuisines[map['RecipeID']]?.add(map['Cuisine']);
      } else {
        _recipeCuisines[map['RecipeID']] = {map['Cuisine']};
      }
    }

    // % OWN
    if (widget.chef) {
      for (var recipe in _recipes) {
        int productsInRecipe = (await db.query(
                'SELECT COUNT(*) FROM USES WHERE RecipeID = ?',
                [recipe['RecipeID']]))
            .first
            .first;
        int ownedProducts = (await db.query(
                'SELECT COUNT(*) FROM OWNS NATURAL JOIN '
                '(SELECT ProductName, Amount as RecipeAmount '
                'FROM USES WHERE RecipeID = ?) AS TEMP '
                'WHERE Email = ? AND OWNS.Amount >= RecipeAmount',
                [recipe['RecipeID'], widget.email]))
            .first
            .first;
        recipe['% Owned'] = (ownedProducts / productsInRecipe) * 100;
      }
    }

    setState(() {
      _filteredList = _filter();
    });
  }

  List<Map<String, dynamic>> _filter() {
    // deep copy
    List<Map<String, dynamic>> filtered =
        _recipes.map((e) => Map<String, dynamic>.of(e)).toList();
    List<int> invalidRecipeIDs = [];

    // find recipes that do not contain at least one of the filters then remove them
    for (TextFormField dietTag in _dietTags) {
      if (dietTag.controller?.text != null &&
          dietTag.controller?.text.trim() != '') {
        for (MapEntry<int, Set<String>> recipe in _recipeDietTags.entries) {
          if (!recipe.value
              .map((e) => e.toLowerCase())
              .contains(dietTag.controller?.text.trim().toLowerCase())) {
            invalidRecipeIDs.add(recipe.key);
          }
        }
      }
    }

    // remove invalid diettags to make cuisine loop faster
    filtered.removeWhere(
        (element) => invalidRecipeIDs.contains(element['RecipeID']));
    // print(filtered);

    // do the same with cuisines
    for (TextFormField cuisine in _cuisines) {
      if (cuisine.controller?.text != null &&
          cuisine.controller?.text.trim() != '') {
        for (MapEntry<int, Set<String>> recipe in _recipeCuisines.entries) {
          if (!recipe.value
              .map((e) => e.toLowerCase())
              .contains(cuisine.controller?.text.trim().toLowerCase())) {
            invalidRecipeIDs.add(recipe.key);
          }
        }
      }
    }

    // remove invalid again
    filtered.removeWhere(
        (element) => invalidRecipeIDs.contains(element['RecipeID']));
    // print(filtered);

    return filtered;
  }

  void _save(int id) async {
    if (_mealKey.currentState?.validate() ?? false) {
      _mealKey.currentState?.save();
      await db.query('INSERT INTO MEAL VALUES (?, ?, ?)',
          [id, widget.email, formatter.format(_date!)]);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Widget _buildRecipeView(int id) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Recipe(
            formKey: GlobalKey<FormState>(),
            editable: false,
            chef: widget.chef,
            id: id,
            email: widget.email,
          ),
          Visibility(
            visible: widget.chef,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => _buildMeal(id)));
                  },
                  child: const Text('Plan Meal')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeal(int id) {
    return CenterForm(
        title: 'Recipe - Plan Meal',
        formKey: _mealKey,
        children: [
          SizedBox(
            width: 200,
            child: InputDatePickerFormField(
              initialDate: DateTime.now(),
              lastDate: DateTime(DateTime.now().year + 100),
              errorInvalidText: 'Invalid date',
              errorFormatText: 'Must be in date format',
              firstDate: DateTime.now(),
              onDateSubmitted: (_) => _save(id),
              onDateSaved: (date) {
                _date = date;
              },
            ),
          ),
          Visibility(
            visible: widget.chef,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: ElevatedButton(
                  onPressed: () => _save(id), child: const Text('Save')),
            ),
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                MultiField(
                  fields: _dietTags,
                  field: dietTagField,
                  onSubmit: (_) => setState(() {
                    _filteredList = _filter();
                  }),
                  editable: true,
                ),
                MultiField(
                  fields: _cuisines,
                  field: cuisineField,
                  onSubmit: (_) => setState(() {
                    _filteredList = _filter();
                  }),
                  editable: true,
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .75),
            child: SingleChildScrollView(
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
                        '% Owned',
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
                rows: _filteredList
                    .map<DataRow>((recipe) => DataRow(
                            cells: [
                              DataCell(Text('${recipe['RecipeID']}')),
                              DataCell(Text(recipe['Name'])),
                              DataCell(Text(recipe['Author'])),
                              DataCell(Text(_recipeCuisines[recipe['RecipeID']]
                                      ?.join(', ') ??
                                  '')),
                              DataCell(Text(_recipeDietTags[recipe['RecipeID']]
                                      ?.join(', ') ??
                                  '')),
                              DataCell(
                                  Text('${recipe['Rating'] ?? 'No Ratings'}')),
                              DataCell(Text(
                                  recipe['% Owned']?.toStringAsFixed(2) ??
                                      'N/A'))
                            ],
                            onSelectChanged: (selected) {
                              if (selected ?? false) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        _buildRecipeView(recipe['RecipeID'])));
                              }
                            }))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
