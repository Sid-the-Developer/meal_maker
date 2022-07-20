import 'package:flutter/material.dart';
import 'package:meal_planner/widgets/recipe.dart';

import '../globals.dart';
import '../widgets/multifield.dart';

class BrowseRecipes extends StatefulWidget {
  const BrowseRecipes({Key? key, this.recipes = const []}) : super(key: key);
  final List recipes;

  @override
  State<StatefulWidget> createState() => BrowseRecipesState();
}

class BrowseRecipesState extends State<BrowseRecipes> {
  late List _recipes = [
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
  final List<Widget> _dietTags = [];
  final List<Widget> _cuisines = [];
  bool _sortAsc = true;

  @override
  void initState() {
    // TODO: initialize _recipes with matching query
    super.initState();
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
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .5),
          child: DataTable(
            showCheckboxColumn: false,
            sortAscending: _sortAsc,
            sortColumnIndex: 5,
            border: TableBorder.all(),
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
            ],
            rows: _recipes
                .map<DataRow>((recipe) => DataRow(
                        cells: [
                          DataCell(Text(recipe.id.toString())),
                          DataCell(Text(recipe.name!)),
                          DataCell(Text(recipe.author!)),
                          DataCell(Text(recipe.cuisines!)),
                          DataCell(Text(recipe.dietTags!)),
                          DataCell(Text(recipe.rating.toString()))
                        ],
                        onSelectChanged: (selected) {
                          if (selected ?? false) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => recipe,
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
