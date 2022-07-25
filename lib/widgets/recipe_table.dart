import 'package:flutter/material.dart';
import 'package:meal_planner/globals.dart';
import 'package:meal_planner/widgets/recipe.dart';

class RecipeTable extends StatefulWidget {
  const RecipeTable({Key? key, required this.email, required this.chef})
      : super(key: key);
  final String email;
  final bool chef;

  @override
  State<StatefulWidget> createState() => RecipeTableState();
}

class RecipeTableState extends State<RecipeTable> {
  List<Map<String, dynamic>> _recipes = [];
  int _sortIndex = 0;
  bool _sortAsc = true;

  @override
  void initState() {
    super.initState();
    _sortName().then((value) => setState(() => _recipes = value));
  }

  Future<List<Map<String, dynamic>>> _sortName() async => dbResultToMap(
      await db.query(
          'SELECT RECIPE.RecipeID, RecipeName, AVG(Rating) '
          'FROM RECIPE LEFT OUTER JOIN REVIEW '
          'ON RECIPE.RecipeID = REVIEW.RecipeID '
          'WHERE RECIPE.Email = ? '
          'GROUP BY RECIPE.RecipeID '
          'ORDER BY RecipeName ${_sortAsc ? 'ASC' : 'DESC'}',
          [widget.email]),
      ['RecipeID', 'Name', 'Rating']);

  Future<List<Map<String, dynamic>>> _sortRating() async => dbResultToMap(
      await db.query(
          'SELECT RECIPE.RecipeID, RecipeName, AVG(Rating) as Avg '
          'FROM RECIPE LEFT OUTER JOIN REVIEW '
          'ON RECIPE.RecipeID = REVIEW.RecipeID '
          'WHERE RECIPE.Email = ? '
          'GROUP BY RECIPE.RecipeID '
          'ORDER BY Avg ${_sortAsc ? 'ASC' : 'DESC'}',
          [widget.email]),
      ['RecipeID', 'Name', 'Rating']);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'My Recipes',
            style: TextStyle(fontSize: 25),
          ),
        ),
        ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .3),
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
                DataColumn(
                    label: const Center(
                        child: Text(
                      'Name',
                      textAlign: TextAlign.center,
                    )),
                    onSort: (index, asc) {
                      setState(() {
                        _sortAsc = asc;
                        _sortIndex = index;
                        _sortName().then((value) => _recipes = value);
                      });
                    }),
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
                        _sortRating().then((value) => _recipes = value);
                      });
                    })
              ],
              rows: _recipes
                  .map<DataRow>((recipe) => DataRow(
                          cells: [
                            DataCell(Text('${recipe['RecipeID']}')),
                            DataCell(Text('${recipe['Name']}')),
                            DataCell(
                                Text('${recipe['Rating'] ?? 'No Ratings'}'))
                          ],
                          onSelectChanged: (selected) {
                            if (selected ?? false) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Recipe(
                                  formKey: GlobalKey<FormState>(),
                                  id: recipe['RecipeID'],
                                  chef: widget.chef,
                                  email: widget.email,
                                ),
                              ));
                            }
                          }))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
