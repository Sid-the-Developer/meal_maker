import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/globals.dart';

import 'center_form.dart';

class ReviewTable extends StatefulWidget {
  final List<int> recipeIDs;
  final bool chef;
  final String? recipeName;

  const ReviewTable(
      {Key? key, required this.recipeIDs, this.recipeName, required this.chef})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ReviewTableState();
}

class ReviewTableState extends State<ReviewTable> {
  late List _reviews;
  final _reviewKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _reviews = [
      // placeholder for 3 rows
      Object(), Object(), Object()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      const Spacer(),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '${widget.recipeName ?? ''} - Reviews',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .3),
          child: DataTable(
            showCheckboxColumn: false,
            sortAscending: true,
            sortColumnIndex: 0,
            // border: TableBorder.all(),
            columns: const [
              DataColumn(
                  label: Center(
                    child: Text(
                      'ID',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  numeric: true),
              DataColumn(
                label: Center(
                    child: Text(
                  'User',
                  textAlign: TextAlign.center,
                )),
              ),
              DataColumn(
                label: Center(
                    child: Text(
                  'Rating',
                  textAlign: TextAlign.center,
                )),
                numeric: true,
              ),
              DataColumn(
                label: Center(
                    child: Text(
                  'Comment',
                  textAlign: TextAlign.center,
                )),
              ),
            ],
            rows: widget.recipeIDs
                .map<DataRow>((review) => DataRow(cells: [
                      DataCell(Text('$review')),
                      DataCell(Text('$review Wila')),
                      DataCell(Text('$review 4')),
                      DataCell(Text('$review It was bussin'))
                    ]))
                .toList(),
          ),
        ),
      ),
      Visibility(
        visible: widget.chef,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ReviewPage(
                        formKey: _reviewKey,
                      ))),
              child: const Text('Write Review')),
        ),
      ),
      const Spacer()
    ]);
  }
}

class ReviewPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const ReviewPage({Key? key, required this.formKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage> {
  late int _rating;
  late String? _comment;

  _save() {
    if (widget.formKey.currentState?.validate() ?? false) {
      widget.formKey.currentState?.save();
      // TODO sql
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CenterForm(
      formKey: widget.formKey,
      title: 'Write Review',
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 100,
            child: TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Rating', suffix: Text('/5')),
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                _rating = int.tryParse(value) ?? 1;
                _rating = _rating > 5
                    ? 5
                    : _rating < 1
                        ? 1
                        : _rating;
              },
              validator: nullValidator,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .3,
              maxWidth: MediaQuery.of(context).size.width * .3),
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Comment',
              border: OutlineInputBorder(
                borderSide: BorderSide(),
              ),
            ),
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            onSaved: (comment) => _comment = comment,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value) => _save(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(onPressed: _save, child: const Text('Save')),
        )
      ],
    );
  }
}
