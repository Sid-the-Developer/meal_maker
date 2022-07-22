import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/globals.dart';

import '../widgets/multifield.dart';

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  State<StatefulWidget> createState() => MyProductsPageState();
}

class MyProductsPageState extends State<MyProductsPage> {
  late List<String> _products = [];
  final List<TextFormField> _types = [];
  String? _searchName;

  List<String> _filter() {
    List<String> filtered = _products;
    for (TextFormField type in _types) {
      if (type.controller?.text != '') {
        filtered.addAll(filtered
            .where((product) => 'type'.contains((type.controller?.text)!)));
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Products',
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
              fields: _types,
              field: typeField,
              editable: true,
            ),
            Container(
              width: 200,
              margin: const EdgeInsets.only(left: 16),
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Search by name'),
                onFieldSubmitted: (value) => _searchName = value,
              ),
            )
          ],
        ),
      ),
      ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .5),
          child: DataTable(
            showCheckboxColumn: false,
            // border: TableBorder.all(),
            columns: const [
              DataColumn(
                  label: Center(
                    child: Text(
                      'Name',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  numeric: true),
              DataColumn(
                label: Center(
                    child: Text(
                  'Types',
                  textAlign: TextAlign.center,
                )),
              ),
              DataColumn(
                  label: Center(
                    child: Text(
                      'Units',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  numeric: true),
              DataColumn(
                label: Center(
                  child: Text(
                    'Amount Owned',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            rows: _products
                .map<DataRow>(
                  (product) => DataRow(
                    cells: [
                      DataCell(Text('A name')),
                      DataCell(Text('A type')),
                      DataCell(Text('a unit')),
                      DataCell(TextFormField(
                        decoration: const InputDecoration.collapsed(
                            hintText: 'Update Amount'),
                        initialValue: 'án amount',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onFieldSubmitted: (value) {
                          // TODO change product list and update db
                        },
                      )),
                    ],
                  ),
                )
                .toList(),
          )),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: OutlinedButton(
          child: const Text('Add a new product to db'),
          onPressed: () => addProduct(context).then((_) => setState(() {})),
        ),
      ),
    ]);
  }
}
