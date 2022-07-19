import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'globals.dart';

import 'center_form.dart';
import 'multifield.dart';

final List<String> _allProducts = [];

class ProductTable extends StatefulWidget {
  const ProductTable({Key? key, this.editable = false}) : super(key: key);
  final bool editable;

  @override
  State<StatefulWidget> createState() => ProductTableState();
}

class ProductTableState extends State<ProductTable> {
  final Map<String, int> _recipeProducts = {};

  late int _amount;
  String? _productDropdown;

  Future<bool?> addProduct() async => await showDialog<bool>(
        context: context, builder: (context) => const ProductDialog());

  @override
  Widget build(BuildContext context) {
    var allProducts = _allProducts;
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
                rows: _recipeProducts.entries
                    .map((MapEntry entry) => DataRow(cells: [
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 200,
                              ),
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: entry.key,
                                items: allProducts
                                    .map((product) => DropdownMenuItem<String>(
                                        value: product, child: Text(product)))
                                    .toList(),
                                onChanged: (newProduct) {
                                  if (newProduct != null) {
                                    setState(() {
                                      _recipeProducts.remove(entry.key);
                                      _recipeProducts[newProduct] = entry.value;
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
                            decoration: const InputDecoration(
                              hintText: 'Amount',
                              suffixText: 'g', // TODO complete dynamic units
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: entry.value.toString(),
                            onChanged: (value) {
                              setState(() {
                                _recipeProducts[entry.key] =
                                    int.tryParse(value) ?? 0;
                              });
                            },
                          )),
                          DataCell(Visibility(
                              visible: widget.editable,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  setState(
                                      () => _recipeProducts.remove(entry.key));
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
                  decoration: const InputDecoration(hintText: 'Amount'),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onFieldSubmitted: (amount) {
                    if (_productDropdown != null) {
                      setState(() {
                        _recipeProducts[_productDropdown!] =
                            int.tryParse(amount) ?? 0;
                        _productDropdown = null;
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
                    onPressed: () {
                      if (_productDropdown != null) {
                        setState(() {
                          _recipeProducts[_productDropdown!] = _amount;
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
                onPressed: () => addProduct().then((_) => setState((){})),
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

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        CenterForm(formKey: _productFormKey, children: [
          SizedBox(
            width: 200,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              validator: nullValidator,
              onSaved: (name) => _allProducts.add(name!),
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
          SizedBox(
              width: 400,
              height: 200,
              child: MultiField(
                fields: _typeFields,
                field: typeField,
                editable: true,
              )),
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
                onPressed: () {
                  if (_productFormKey.currentState?.validate() ?? false) {
                    _productFormKey.currentState?.save();

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('${_allProducts.last} added successfully')));
                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text('Save')),
          ),
        ])
      ],
    );
  }
}
