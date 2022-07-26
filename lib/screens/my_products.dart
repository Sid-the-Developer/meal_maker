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
  late List<Map<String, dynamic>> _products = [];
  late final Map<String, Set<String>?> _ingredientTypes = {};
  final List<TextFormField> _types = [];
  late List<Map<String, dynamic>> _filteredList = _filter();
  String? _searchName;

  // add new product to inventory
  String? _productDropdown;
  final GlobalKey<FormFieldState> _amountKey = GlobalKey();
  int? _amount;

  @override
  initState() {
    super.initState();
    _getProductsFromEmail();
    getProducts();
  }

  void _getProductsFromEmail() async {
    _products = dbResultToMap(
        await db.query(
            'SELECT ProductName, ProductType, Units, Amount '
            'FROM PRODUCT NATURAL JOIN OWNS '
            'WHERE Email = ?',
            [widget.email]),
        ['Name', 'Type', 'Units', 'Amount']);

    // add to map with name as key to list of types as value
    var allTypes = dbResultToMap(
        await db.query('SELECT ProductName, ingredientType '
            'FROM INGREDIENT_TYPE NATURAL RIGHT OUTER JOIN PRODUCT'),
        ['Name', 'Type']);
    for (var map in allTypes) {
      if (_ingredientTypes[map['Name']] != null) {
        _ingredientTypes[map['Name']]?.add(map['Type']);
      } else if (map['Type'] == null) {
        _ingredientTypes[map['Name']] = null;
      } else {
        _ingredientTypes[map['Name']] = {map['Type']};
      }
    }

    setState(() {
      _filteredList = _filter();
    });
  }

  List<Map<String, dynamic>> _filter() {
    // deep copy
    List<Map<String, dynamic>> filtered =
        _products.map((e) => Map<String, dynamic>.of(e)).toList();
    List<String> invalidProducts = [];

    // filter the search query first
    if (_searchName != null && _searchName?.trim() != '') {
      filtered
          .where((element) => element['Name'] == _searchName?.toLowerCase());
    }

    // find recipes that do not contain at least one of the filters then remove them
    for (TextFormField type in _types) {
      if (type.controller?.text != null && type.controller?.text.trim() != '') {
        for (MapEntry<String, Set<String>?> product
            in _ingredientTypes.entries) {
          if (!(product.value?.contains(type.controller?.text.trim()) ??
              false)) {
            invalidProducts.add(product.key);
          }
        }
      }
    }

    filtered
        .removeWhere((element) => invalidProducts.contains(element['Name']));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                onSubmit: (type) {
                  setState(() {
                    _filteredList = _filter();
                  });
                },
                editable: true,
              ),
              Container(
                width: 200,
                margin: const EdgeInsets.only(left: 16),
                child: TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Search by name'),
                    onFieldSubmitted: (value) {
                      _searchName = value;
                      setState(() {
                        _filteredList = _filter();
                      });
                    }),
              )
            ],
          ),
        ),
        ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .5),
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
                DataColumn(
                  label: Center(
                    child: Text(
                      'Update Amount',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              rows: _filteredList
                  .map<DataRow>(
                    (product) => DataRow(
                      cells: [
                        DataCell(Text('${product['Name']}')),
                        DataCell(Text(
                            _ingredientTypes[product['Name']]?.join(', ') ??
                                'N/A (${product['Type']})')),
                        DataCell(Text('${product['Units'] ?? 'N/A'}')),
                        DataCell(Text('${product['Amount']}')),
                        DataCell(TextFormField(
                          decoration: const InputDecoration.collapsed(
                              hintText: 'Update Amount'),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onFieldSubmitted: (value) async {
                            await db.query(
                                'UPDATE OWNS '
                                'SET Amount = ? '
                                'WHERE ProductName = ? AND Email = ?',
                                [value, product['Name'], widget.email]);
                            _getProductsFromEmail();
                          },
                        )),
                      ],
                    ),
                  )
                  .toList(),
            )),
        Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _productDropdown,
                      items: allProducts
                          .map((product) => DropdownMenuItem<String>(
                              value: product, child: Text(product)))
                          .toList(),
                      onChanged: (product) {
                        setState(() => _productDropdown = product);
                      },
                      hint: const Text('New Product'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 100,
                    child: TextFormField(
                      key: _amountKey,
                      decoration: const InputDecoration(hintText: 'Amount'),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onFieldSubmitted: (amount) async {
                        if (_productDropdown != null) {
                          await db.query(
                              'INSERT INTO OWNS (Email, ProductName, Amount) VALUES '
                              '(?, ?, ?)',
                              [widget.email, _productDropdown, _amount]);
                          _getProductsFromEmail();
                          _productDropdown = null;
                          _amountKey.currentState?.reset();
                        }
                      },
                      onChanged: (amount) {
                        _amount = int.tryParse(amount) ?? 0;
                      },
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      if (_productDropdown != null) {
                        await db.query(
                            'INSERT INTO OWNS (Email, ProductName, Amount) VALUES '
                            '(?, ?, ?)',
                            [widget.email, _productDropdown, _amount]);
                        _getProductsFromEmail();
                        _productDropdown = null;
                        _amountKey.currentState?.reset();
                      }
                    },
                    icon: const Icon(Icons.add_circle)),
              ],
            )),
      ]),
    );
  }
}
