import 'package:flutter/material.dart';
import 'package:meal_planner/globals.dart';

class GroceryRunTable extends StatefulWidget {
  const GroceryRunTable({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GroceryRunTableState();
}

class GroceryRunTableState extends State<GroceryRunTable> {
  List<GroceryRun> _groceryRuns = [];

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: DataTable(
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
                )))
              ],
              rows: _groceryRuns
                  .map((run) => DataRow(cells: [
                        DataCell(
                          Text('${run.groceryID}'),
                        ),
                        DataCell(Text('${run.date}'))
                      ]))
                  .toList()),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => GroceryRun(
                      date: DateTime.now(),
                      groceryID: _groceryRuns.length + 1,
                    ))),
            //TODO sql insert
            child: const Text('New Run'),
          ),
        )
      ],
    );
  }
}

class GroceryRun extends StatefulWidget {
  const GroceryRun({Key? key, required this.date, required this.groceryID})
      : super(key: key);
  final DateTime date;
  final int groceryID;

  @override
  State<StatefulWidget> createState() => GroceryRunState();
}

class GroceryRunState extends State<GroceryRun> {
  List<String> _checklist = []; //TODO implement sql
  List<String> _meals = [];
  String? _newMeal;
  final GlobalKey<FormFieldState> _dropdownKey = GlobalKey();

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
            Column(
              children: [
                const Text(
                  'Product Checklist',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .3),
                  child: DataTable(
                      showCheckboxColumn: true,
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
                      rows: _checklist
                          .map((run) => DataRow(
                                  onSelectChanged: (selected) {
                                    if (selected != null) {
                                      if (selected) {
                                        // add to db
                                        setState(() => _checklist.add('run'));
                                      } else if (!selected) {
                                        // remove from db
                                        setState(() {
                                          _checklist.remove(run);
                                        });
                                      }
                                    }
                                  },
                                  cells: [
                                    DataCell(Text('_checklist[0] 1st value')),
                                    DataCell(Text('_checklist[0] second value'))
                                  ]))
                          .toList()),
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  'Meals Being Shopped For',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .3),
                  child: DataTable(
                      showCheckboxColumn: true,
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
                      rows: _checklist
                          .map((run) => DataRow(cells: [
                                DataCell(Text('_checklist[0] 1')),
                                DataCell(Text('_checklist[0] 2'))
                              ]))
                          .toList()),
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        key: _dropdownKey,
                        value: _newMeal,
                        validator: nullValidator,
                        items: _meals
                            .map((meal) => DropdownMenuItem<String>(
                                  value: meal,
                                  child: Text('$meal at "a date"'),
                                ))
                            .toList(),
                        onChanged: (value) => _newMeal = value,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          if (_dropdownKey.currentState?.validate() ?? false) {
                            setState(() {
                              _meals.add(_newMeal!);
                              _newMeal = null;
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
