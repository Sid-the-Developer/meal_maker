import 'package:flutter/material.dart';
import 'package:meal_planner/recipe.dart';

class RecipeTable extends StatefulWidget {
  const RecipeTable({Key? key, this.recipes = const []}) : super(key: key);
  final List<Recipe> recipes;

  @override
  State<StatefulWidget> createState() => RecipeTableState();
}

class RecipeTableState extends State<RecipeTable> {
  late List<Recipe> _recipes = widget.recipes;
  int _sortIndex = 0;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .3),
      child: DataTable(
        showCheckboxColumn: false,
        sortAscending: _sortAsc,
        sortColumnIndex: _sortIndex,
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
          DataColumn(
              label: const Center(child: Text('Name', textAlign: TextAlign.center,)),
              onSort: (index, asc) {
                setState(() {
                  _sortAsc = asc;
                  _sortIndex = index;
                  _recipes.sort((a, b) => a.name!.compareTo(b.name!));
                  if (!asc) {
                    _recipes = _recipes.reversed.toList();
                  }
                });
              }),
          DataColumn(
              label: const Center(child: Text('Avg Rating', textAlign: TextAlign.center,)),
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
              })
        ],
        rows: _recipes
            .map<DataRow>((recipe) => DataRow(
                    cells: [
                      DataCell(Text(recipe.id.toString())),
                      DataCell(Text(recipe.name!)),
                      DataCell(Text(recipe.rating.toString()))
                    ],
                    onSelectChanged: (selected) {
                      if (selected ?? false) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Scaffold(
                                  appBar: AppBar(),
                                  body: recipe,
                                )));
                      }
                    }))
            .toList(),
      ),
    );
  }
}
