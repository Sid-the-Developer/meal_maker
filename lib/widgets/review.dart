import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/globals.dart';

import 'center_form.dart';

class ReviewTable extends StatefulWidget {
  final int recipeID;
  final bool chef;
  final String? recipeName;
  final String email;

  const ReviewTable(
      {Key? key,
      required this.recipeID,
      required this.recipeName,
      required this.chef,
      required this.email})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ReviewTableState();
}

class ReviewTableState extends State<ReviewTable> {
  late List<Map<String, dynamic>> _reviews = [];
  final _reviewKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _parseReviewsFromRecipeID();
  }

  void _parseReviewsFromRecipeID() async {
    _reviews = dbResultToMap(
        await db.query(
            'SELECT ReviewID, Name, Rating, ReviewComment '
            'FROM USER NATURAL JOIN REVIEW '
            'WHERE RecipeID = ?',
            [widget.recipeID]),
        ['ReviewID', 'User', 'Rating', 'Comment']);
    setState(() {});
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
          child: SingleChildScrollView(
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
                      child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Comment',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                    ),
                  )),
                ),
              ],
              rows: _reviews
                  .map<DataRow>((review) => DataRow(cells: [
                        DataCell(Text('${review['ReviewID']}')),
                        DataCell(Text('${review['User']}')),
                        DataCell(Text('${review['Rating']}')),
                        DataCell(Text('${review['Comment'] ?? ''}'))
                      ]))
                  .toList(),
            ),
          ),
        ),
      ),
      Visibility(
        visible: widget.chef,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ReviewPage(
                          formKey: _reviewKey,
                          recipeID: widget.recipeID,
                          email: widget.email,
                        )));
                setState(() {});
              },
              child: const Text('Write Review')),
        ),
      ),
      const Spacer()
    ]);
  }
}

class ReviewPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String email;
  final int recipeID;

  const ReviewPage(
      {Key? key,
      required this.formKey,
      required this.email,
      required this.recipeID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage> {
  late int _rating;
  late String? _comment;

  _save() {
    if (widget.formKey.currentState?.validate() ?? false) {
      widget.formKey.currentState?.save();

      db.query(
          'INSERT INTO REVIEW (Email, RecipeID, ReviewComment, Rating) '
          'VALUES (?, ?, ?, ?)',
          [widget.email, widget.recipeID, _comment, _rating]);

      if (mounted) Navigator.of(context).pop();
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
