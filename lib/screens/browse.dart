import 'package:flutter/material.dart';
import 'package:meal_planner/widgets/center_form.dart';
import 'package:meal_planner/widgets/recipe.dart';

import '../globals.dart';
import '../widgets/multifield.dart';

class BrowseRecipes extends StatefulWidget {
  const BrowseRecipes({Key? key, this.recipes = const [], required this.chef})
      : super(key: key);
  final List recipes;
  final bool chef;

  @override
  State<StatefulWidget> createState() => BrowseRecipesState();
}

class BrowseRecipesState extends State<BrowseRecipes> {
  late List<Recipe> _recipes = [
    Recipe(
      name: 'Paella',
      rating: 4,
      author: 'Wila',
      id: 1,
      cuisines: 'cuisines',
      dietTags: 'diet tags',
      formKey: GlobalKey<FormState>(),
    ),
    Recipe(
      name: 'Bomba',
      rating: 3,
      author: 'Rob',
      id: 3,
      cuisines: 'cuisines',
      dietTags: 'diet tags',
      formKey: GlobalKey<FormState>(),
    )
  ];
  final List<TextFormField> _dietTags = [];
  final List<TextFormField> _cuisines = [];

  bool _sortAsc = true;
  int _sortIndex = 0;
  GlobalKey<FormState> _mealKey = GlobalKey();
  int? year;
  int? month;
  int? day;

  List<Widget> _filter() {
    List<Recipe> filtered = _recipes;
    for (TextFormField dietTag in _dietTags) {
      if (dietTag.controller?.text != '') {
        filtered.addAll(filtered.where((recipe) =>
            recipe.dietTags?.contains((dietTag.controller?.text)!) ?? true));
      }
    }

    for (TextFormField cuisine in _cuisines) {
      if (cuisine.controller?.text != '') {
        filtered.addAll(filtered.where((recipe) =>
            recipe.cuisines?.contains((cuisine.controller?.text)!) ?? true));
      }
    }

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
                      _recipes.sort((a, b) => a.rating!.compareTo(b.rating!));
                      if (!asc) {
                        _recipes = _recipes.reversed.toList();
                      }
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
                      _recipes.sort((a, b) => a.rating!.compareTo(b.rating!));
                      if (!asc) {
                        _recipes = _recipes.reversed.toList();
                      }
                    });
                  }),
            ],
            rows: _recipes
                .map<DataRow>((recipe) => DataRow(
                        cells: [
                          DataCell(Text(recipe.id.toString())),
                          DataCell(Text(recipe.name!)),
                          DataCell(Text(recipe.author!)),
                          DataCell(Text(recipe.cuisines!)),
                          DataCell(Text(recipe.dietTags!)),
                          DataCell(Text(recipe.rating.toString())),
                          DataCell(Text(widget.chef ? ' ' : 'N/A'))
                        ],
                        onSelectChanged: (selected) {
                          if (selected ?? false) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  recipe,
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
