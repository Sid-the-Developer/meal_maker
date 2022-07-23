import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mysql1/mysql1.dart';
import '../globals.dart';

import 'center_form.dart';
import 'multifield.dart';

// initialize product list
List<String> _allProducts = [];

class ProductTable extends StatefulWidget {
  const ProductTable(
      {Key? key,
      this.editable = false,
      this.chef = false,
      this.recipeIDs = const []})
      : super(key: key);
  final bool editable;
  final bool chef;
  final List<int> recipeIDs;
  final Map<String, List> _recipeProducts = const {};

  addToDB(int recipeID) {
    // save products to uses
    db.queryMulti(
        'INSERT INTO USES (RecipeID, ProductName, Amount) '
        'VALUES (?, ?, ?)',
        _recipeProducts.entries
            .map((entry) => [recipeID, entry.key, entry.value])
            .toList());
  }

  @override
  State<StatefulWidget> createState() => ProductTableState();
}

class ProductTableState extends State<ProductTable> {
  late int _amount;
  String? _productDropdown;
  final GlobalKey<FormFieldState> _amountKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _parseProductsFromRecipes();
    _getProducts();
  }

  _getProducts() async {
    _allProducts = List<String>.of((await db.query('SELECT ProductName '
            'FROM PRODUCT'))
        .map((row) => row[0]));
  }

  _parseProductsFromRecipes() async {
    for (int id in widget.recipeIDs) {
      Results products = await db.query(
          'SELECT ProductName, Amount, Units '
          'FROM USES WHERE RecipeID = ?',
          [id]);
      for (var product in products) {
        widget._recipeProducts[product[0]] = [product[1], product[2]];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: DataTable(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                columns: const [
                  DataColumn(label: Text('Product Name')),
                  DataColumn(label: Text('Amount'), numeric: true),
                  DataColumn(label: Text(''))
                ],
                rows: widget._recipeProducts.entries
                    .map((MapEntry entry) => DataRow(cells: [
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 200,
                              ),
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: entry.key,
                                items: _allProducts
                                    .map((product) => DropdownMenuItem<String>(
                                        value: product, child: Text(product)))
                                    .toList(),
                                onChanged: (newProduct) {
                                  if (newProduct != null) {
                                    setState(() {
                                      widget._recipeProducts.remove(entry.key);
                                      widget._recipeProducts[newProduct] =
                                          entry.value;
                                    });
                                  }
                                },
                                hint: const Text('Product'),
                                decoration: const InputDecoration.collapsed(
                                    hintText: 'Product'),
                              ),
                            ),
                          ),
                          DataCell(TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Amount',
                              suffixText:
                                  entry.value[1], // TODO complete dynamic units
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: entry.value[0].toString(),
                            onChanged: (value) {
                              setState(() {
                                widget._recipeProducts[entry.key]![0] =
                                    int.tryParse(value) ?? 0;
                              });
                            },
                          )),
                          DataCell(Visibility(
                              visible: widget.editable,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  setState(() =>
                                      widget._recipeProducts.remove(entry.key));
                                },
                              )))
                        ]))
                    .toList()),
          ),
        ),
        Visibility(
            visible: widget.editable,
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
                      items: _allProducts
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
                          Results units = await db.query(
                              'SELECT Units '
                              'FROM PRODUCT WHERE ProductName = ?',
                              [_productDropdown]);
                          setState(() {
                            widget._recipeProducts[_productDropdown!] = [
                              int.tryParse(amount) ?? 0,
                              units.first.first
                            ];
                            _productDropdown = null;
                            _amountKey.currentState?.reset();
                          });
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
                        Results units = await db.query(
                            'SELECT Units '
                            'FROM PRODUCT WHERE ProductName = ?',
                            [_productDropdown]);
                        setState(() {
                          widget._recipeProducts[_productDropdown!] = [
                            _amount,
                            units.first.first
                          ];
                          _productDropdown = null;
                        });
                      }
                    },
                    icon: const Icon(Icons.add_circle)),
              ],
            )),
        Visibility(
          visible: widget.editable,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: OutlinedButton(
              child: const Text('Add a new product to db'),
              onPressed: () => addProduct(context).then((_) => setState(() {})),
            ),
          ),
        )
      ],
    );
  }
}

class ProductDialog extends StatefulWidget {
  const ProductDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ProductDialogState();
}

class ProductDialogState extends State<ProductDialog> {
  final GlobalKey<FormState> _productFormKey = GlobalKey();
  bool _isTool = false;
  final List<TextFormField> _typeFields = [];
  late final String? _units;
  late final String? _name;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height * .5,
            width: MediaQuery.of(context).size.width * .5,
            child: SingleChildScrollView(
              child: CenterForm(
                  formKey: _productFormKey,
                  title: 'Add Product',
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Name'),
                        textInputAction: TextInputAction.next,
                        validator: nullValidator,
                        onSaved: (name) => _name = name,
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Units'),
                        textInputAction: TextInputAction.next,
                        validator: nullValidator,
                        onChanged: (value) {
                          _units = value;
                        },
                      ),
                    ),
                    MultiField(
                      fields: _typeFields,
                      field: typeField,
                      editable: true,
                    ),
                    SizedBox(
                      width: 200,
                      child: SwitchListTile(
                        value: _isTool,
                        onChanged: (value) {
                          setState(() {
                            _isTool = value;
                          });
                        },
                        title: const Text('Tool'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_productFormKey.currentState?.validate() ??
                                false) {
                              _productFormKey.currentState?.save();
                              db.query('INSERT INTO PRODUCT VALUES (?, ?, ?)', [
                                _name,
                                _units,
                                _isTool ? 'Tool' : 'Ingredient'
                              ]);
                              db.queryMulti(
                                  'INSERT INTO INGREDIENT_TYPE VALUES (?, ?)',
                                  _typeFields
                                      .map((type) =>
                                          [_name, type.controller?.text])
                                      .toList());

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        '${_allProducts.last} added successfully')));
                                Navigator.of(context).pop(true);
                              }
                            }
                          },
                          child: const Text('Save')),
                    ),
                  ]),
            ))
      ],
    );
  }
}
