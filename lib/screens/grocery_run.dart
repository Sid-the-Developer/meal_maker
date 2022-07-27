import 'package:flutter/material.dart';
import 'package:meal_planner/globals.dart';

import '../meal.dart';

class GroceryRunTable extends StatefulWidget {
  const GroceryRunTable({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  State<StatefulWidget> createState() => GroceryRunTableState();
}

class GroceryRunTableState extends State<GroceryRunTable> {
  List<Map<String, dynamic>> _groceryRuns = [];

  @override
  void initState() {
    super.initState();
    _parseRunsFromEmail();
  }

  void _parseRunsFromEmail() async {
    _groceryRuns = dbResultToMap(
        await db.query(
            'SELECT GroceryID, Date FROM GROCERY_RUN WHERE Email = ?',
            [widget.email]),
        ['ID', 'Date']);
    for (var run in _groceryRuns) {
      run['Date'] = formatter.format(run['Date']);
    }
    setState(() {});
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
              'Grocery Runs',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: DataTable(
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(
                        label: Center(
                            child: Text(
                      'ID',
                      textAlign: TextAlign.center,
                    ))),
                    DataColumn(
                        label: Center(
                            child: Text(
                      'Date',
                      textAlign: TextAlign.center,
                    ))),
                    DataColumn(
                        label: Center(
                            child: Text(
                      '',
                      textAlign: TextAlign.center,
                    )))
                  ],
                  rows: _groceryRuns
                      .map((run) => DataRow(
                              cells: [
                                DataCell(
                                  Text('${run['ID']}'),
                                ),
                                DataCell(Text('${run['Date']}')),
                                DataCell(Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: () async {
                                      await db.query(
                                          'DELETE FROM GROCERY_RUN WHERE GroceryID = ?',
                                          [
                                            run['ID']
                                          ]).then(
                                          (value) => _parseRunsFromEmail());
                                    },
                                  ),
                                ))
                              ],
                              onSelectChanged: (selected) {
                                if (selected ?? false) {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => GroceryRun(
                                                date: formatter
                                                    .parseStrict(run['Date']),
                                                groceryID: run['ID'],
                                                email: widget.email,
                                              )))
                                      .then((value) => _parseRunsFromEmail());
                                }
                              }))
                      .toList()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                int newID = (await db.query(
                        'INSERT INTO GROCERY_RUN (Email, Date) VALUES (?, ?)',
                        [widget.email, formatter.format(DateTime.now())]))
                    .insertId!;
                if (mounted) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => GroceryRun(
                                date: DateTime.now(),
                                groceryID: newID,
                                email: widget.email,
                              )))
                      .then((value) => _parseRunsFromEmail());
                }
              },
              child: const Text('New Run'),
            ),
          )
        ],
      ),
    );
  }
}

class GroceryRun extends StatefulWidget {
  const GroceryRun(
      {Key? key,
      required this.date,
      required this.groceryID,
      required this.email})
      : super(key: key);
  final DateTime date;
  final int groceryID;
  final String email;

  @override
  State<StatefulWidget> createState() => GroceryRunState();
}

class GroceryRunState extends State<GroceryRun> {
  List<Meal> _checklist = [];
  List<Meal> _allMeals = [];
  List<Meal> _runMeals = [];
  late final List<bool> _selectedRows =
      _checklist.map<bool>((meal) => meal.mealMap['Amount'] <= 0).toList();
  Meal? _newMeal;
  final GlobalKey<FormFieldState> _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _buildChecklistFromID();
  }

  void _buildChecklistFromID() async {
    _allMeals = dbResultToMap(
        await db.query(
            'SELECT RECIPE.RecipeID, RecipeName, MEAL.Email, PrepareDate '
            'FROM MEAL JOIN RECIPE ON MEAL.RecipeID = RECIPE.RecipeID AND MEAL.Email = ?',
            [widget.email]),
        [
          'RecipeID',
          'RecipeName',
          'Email',
          'PrepareDate'
        ]).map((e) => Meal(e)).toList();
    for (var run in _allMeals) {
      run.mealMap['PrepareDate'] = formatter.format(run.mealMap['PrepareDate']);
    }

    _runMeals = dbResultToMap(
        await db.query(
            'SELECT RECIPE.RecipeID, RecipeName, MEAL.Email, PrepareDate, GroceryID '
            'FROM MEAL NATURAL JOIN SOURCES NATURAL JOIN GROCERY_RUN '
            'JOIN RECIPE ON RECIPE.RecipeID = MEAL.RecipeID '
            'WHERE GroceryID = ?',
            [widget.groceryID]),
        [
          'RecipeID',
          'RecipeName',
          'Email',
          'PrepareDate',
          'GroceryID'
        ]).map((e) => Meal(e)).toList();
    for (var run in _runMeals) {
      run.mealMap['PrepareDate'] = formatter.format(run.mealMap['PrepareDate']);
    }

    List<int> recipeIDs =
        _runMeals.map<int>((e) => e.mealMap['RecipeID']).toList();

    if (recipeIDs.isNotEmpty) {
      _checklist = dbResultToMap(
          await db.query(
              'SELECT ProductName, Amount, SUM(Amount) '
              'FROM USES WHERE RecipeID IN (${recipeIDs.map((e) => '?').join(', ')}) '
              'GROUP BY ProductName',
              [...recipeIDs]),
          ['Name', 'RecipeAmount', 'TotalAmount']).map((e) => Meal(e)).toList();
    } else {
      _checklist = [];
    }

    Map<String, int> ownedAmounts = {
      // LEFT OUTER JOIN so that a not owned product will return null
      for (var product in await db.query(
          'SELECT PRODUCT.ProductName, Amount FROM PRODUCT NATURAL LEFT OUTER JOIN '
          '(SELECT * FROM OWNS WHERE Email = ?) AS TEMP',
          [widget.email]))
        product[0]: product[1] ?? 0
    };

    for (var product in _checklist) {
      product.mealMap['OwnedAmount'] =
          ownedAmounts[product.mealMap['Name']] ?? 0;
      product.mealMap['Amount'] =
          (product.mealMap['TotalAmount'] - product.mealMap['OwnedAmount']);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Grocery Run - ${widget.date.toString().substring(0, 10)}',
            style: const TextStyle(fontSize: 25),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Product Checklist',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .3,
                        maxHeight: MediaQuery.of(context).size.height * .5),
                    child: SingleChildScrollView(
                      child: DataTable(
                          columns: const [
                            DataColumn(
                                label: Center(
                                    child: Text(
                              'Name',
                              textAlign: TextAlign.center,
                            ))),
                            DataColumn(
                                label: Center(
                                    child: Text(
                              'Amount',
                              textAlign: TextAlign.center,
                            )))
                          ],
                          rows: List.generate(
                              _checklist.length,
                              (i) => DataRow(
                                      selected: _selectedRows[i],
                                      onSelectChanged: (selected) async {
                                        if (selected != null) {
                                          setState(() {
                                            _selectedRows[i] = selected;
                                          });
                                          if (selected) {
                                            // add to db
                                            await db.query(
                                                'INSERT INTO OBTAINS (GroceryID, Price, ProductName, Amount) '
                                                'VALUES (?, ?, ?, ?)',
                                                [
                                                  widget.groceryID,
                                                  0,
                                                  _checklist[i].mealMap['Name'],
                                                  _checklist[i]
                                                      .mealMap['Amount']
                                                ]);
                                            await db.query(
                                                'INSERT INTO OWNS VALUES (?, ?, ?)',
                                                [
                                                  widget.email,
                                                  _checklist[i].mealMap['Name'],
                                                  _checklist[i]
                                                      .mealMap['TotalAmount'],
                                                ]);
                                            await db.query(
                                                'UPDATE OWNS SET Amount = ? '
                                                'WHERE ProductName = ? AND Email = ?',
                                                [
                                                  _checklist[i]
                                                      .mealMap['TotalAmount'],
                                                  _checklist[i].mealMap['Name'],
                                                  widget.email
                                                ]);
                                          } else if (!selected) {
                                            // remove from db
                                            num amountObtained = num.parse(
                                                (await db.query(
                                                        'SELECT Amount FROM OBTAINS WHERE GroceryID = ? AND ProductName = ?',
                                                        [
                                                  widget.groceryID,
                                                  _checklist[i].mealMap['Name']
                                                ]))
                                                    .first
                                                    .first);
                                            print(amountObtained);

                                            if (amountObtained ==
                                                _checklist[i]
                                                    .mealMap['OwnedAmount']) {
                                              await db.query(
                                                  'UPDATE OWNS SET Amount = ? '
                                                  'WHERE ProductName = ? AND Email = ?',
                                                  [
                                                    _checklist[i].mealMap[
                                                            'OwnedAmount'] -
                                                        amountObtained,
                                                    _checklist[i]
                                                        .mealMap['Name'],
                                                    widget.email
                                                  ]);
                                            } else {
                                              await db.query(
                                                  'DELETE FROM OWNS '
                                                  'WHERE ProductName = ? AND Email = ?',
                                                  [
                                                    _checklist[i]
                                                        .mealMap['Name'],
                                                    widget.email
                                                  ]);
                                            }
                                            await db.query(
                                                'DELETE FROM OBTAINS WHERE GroceryID = ? AND ProductName = ?',
                                                [
                                                  widget.groceryID,
                                                  _checklist[i].mealMap['Name'],
                                                ]);
                                          }
                                          _buildChecklistFromID();
                                        }
                                      },
                                      cells: [
                                        DataCell(Text(
                                            '${_checklist[i].mealMap['Name']}')),
                                        DataCell(Text(
                                            '${(_checklist[i].mealMap['Amount'] ?? 0) > 0 ? _checklist[i].mealMap['Amount'] : _checklist[i].mealMap['TotalAmount']}'))
                                      ]))),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text(
                  'Meals Being Shopped For',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width),
                  child: DataTable(
                      showCheckboxColumn: false,
                      columns: const [
                        DataColumn(
                            label: Center(
                                child: Text(
                          'Name',
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Center(
                                child: Text(
                          'Date Planned',
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Center(
                                child: Text(
                          '',
                          textAlign: TextAlign.center,
                        )))
                      ],
                      rows: _runMeals
                          .map((run) => DataRow(cells: [
                                DataCell(Text('${run.mealMap['RecipeName']}')),
                                DataCell(Text('${run.mealMap['PrepareDate']}')),
                                DataCell(Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: () async {
                                      await db.query(
                                          'DELETE FROM SOURCES WHERE GroceryID = ? '
                                          'AND RecipeID = ? AND Email = ? AND PrepareDate = ?',
                                          [
                                            widget.groceryID,
                                            run.mealMap['RecipeID'],
                                            run.mealMap['Email'],
                                            run.mealMap['PrepareDate']
                                          ]);
                                      _newMeal = null;
                                      _buildChecklistFromID();
                                    },
                                  ),
                                ))
                              ]))
                          .toList()),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        constraints:
                            const BoxConstraints(minWidth: 200, maxWidth: 400),
                        margin: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: DropdownButtonFormField<Meal>(
                          key: _dropdownKey,
                          value: _newMeal,
                          validator: (meal) =>
                              nullValidator(meal?.mealMap['RecipeName']),
                          items: _allMeals
                              .map((meal) => DropdownMenuItem<Meal>(
                                  value: meal,
                                  child: Text(
                                    '${meal.mealMap['RecipeName']} on ${meal.mealMap['PrepareDate']}',
                                    overflow: TextOverflow.fade,
                                  )))
                              .toList(),
                          onChanged: (value) => _newMeal = value,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () async {
                          if (_dropdownKey.currentState?.validate() ?? false) {
                            await db.query(
                                'INSERT INTO SOURCES VALUES (?, ?, ?, ?)', [
                              widget.groceryID,
                              _newMeal!.mealMap['RecipeID'],
                              _newMeal!.mealMap['Email'],
                              _newMeal!.mealMap['PrepareDate']
                            ]).then((value) {
                              setState(() {
                                _newMeal = null;
                              });
                              _buildChecklistFromID();
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
