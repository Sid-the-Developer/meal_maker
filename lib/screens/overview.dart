import 'package:flutter/material.dart';
import 'package:meal_planner/screens/browse.dart';
import 'package:meal_planner/screens/grocery_run.dart';
import 'package:meal_planner/screens/login.dart';
import 'package:meal_planner/screens/my_products.dart';
import 'package:meal_planner/widgets/recipe.dart';
import 'package:meal_planner/widgets/recipe_table.dart';
import 'package:mysql1/mysql1.dart';

import '../globals.dart';

final GlobalKey<FormState> _recipeKey = GlobalKey();
TabController? _tabController;

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage>
    with TickerProviderStateMixin {
  final GlobalKey<NavigatorState> _tab1Key = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _tab2Key = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _tab3Key = GlobalKey<NavigatorState>();
  int keyCount = 0;
  late final List<GlobalKey<NavigatorState>> _tabKeys = [
    _tab1Key,
    _tab2Key,
    _tab3Key
  ];
  ValueNotifier<bool> chef = ValueNotifier(false);
  late final double avgRating;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<bool> setAvgRating() async {
    try {
      avgRating = (await db.query(
              'SELECT AVG(Rating) '
              'FROM REVIEW '
              'WHERE REVIEW.Email = ? '
              'GROUP BY Email',
              [widget.email]))
          .first
          .first;
      return true;
    } on Error catch (_) {
      avgRating = 0;
      return false;
    }
  }

  List<Widget> _buildTabs() {
    return [
      ValueListenableBuilder(
          valueListenable: chef,
          builder: (context, bool newChef, _) {
            return Visibility(
              visible: newChef,
              replacement: Recipe(
                formKey: _recipeKey,
                editable: true,
                email: widget.email,
              ),
              child: const GroceryRunTable(),
            );
          }),
      ValueListenableBuilder(
          valueListenable: chef,
          builder: (context, bool newChef, _) {
            return Center(
                child: BrowseRecipes(
                  chef: newChef,
              email: widget.email,
            ));
          }),
      ValueListenableBuilder(
          valueListenable: chef,
          builder: (context, bool newChef, _) {
            return Visibility(
                visible: newChef,
                replacement: Center(
                    child: RecipeTable(
                  email: widget.email,
                )),
                child: MyProductsPage(email: widget.email));
          }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<bool?>>(
      future: Future.wait([
        setAvgRating(),
        Future.delayed(
            const Duration(microseconds: 1),
            () => showDialog<bool>(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('Home Selection'),
                    children: [
                      SimpleDialogOption(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true)
                                  .pop(false),
                          child: const Text('Contributor')),
                      SimpleDialogOption(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true)
                                  .pop(true),
                          child: const Text('Chef'))
                    ],
                  );
                }))
      ]),
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.done
          ? Scaffold(
              appBar: AppBar(
                leading: const BackButton(),
                title: Text.rich(
                  TextSpan(
                      text: '${chef.value ? 'Chef' : 'Contributor'} Home\n',
                      children: [
                        TextSpan(
                            text: avgRating > 0
                                ? 'Avg Rating: $avgRating/5.0'
                                : 'No ratings',
                            style: TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 14))
                      ]),
                  textAlign: TextAlign.center,
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          chef.value = !chef.value;
                        });
                        _tabKeys[_tabController!.index]
                            .currentState!
                            .popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.change_circle_outlined)),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                      },
                      icon: const Icon(Icons.logout_outlined))
                ],
                bottom: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Text(chef.value ? 'Grocery Runs' : 'Write Recipe'),
                    ),
                    const Tab(
                      child: Text('Browse Recipes'),
                    ),
                    Tab(
                      child: Text('My ${chef.value ? 'Products' : 'Recipes'}'),
                    )
                  ],
                ),
              ),
              body: TabBarView(
                  controller: _tabController,
                  children: _buildTabs().map((tab) {
                    GlobalKey<NavigatorState> tabKey = _tabKeys[keyCount];
                    Widget view = WillPopScope(
                      onWillPop: () async =>
                          !(await tabKey.currentState?.maybePop() ?? false),
                      child: Navigator(
                        // nested navigator to keep appbar
                        key: tabKey,
                        onGenerateRoute: (settings) {
                          return MaterialPageRoute<dynamic>(
                            builder: (context) {
                              return tab;
                            },
                            settings: settings,
                          );
                        },
                      ),
                    );

                    keyCount = (keyCount + 1) % 3;

                    return view;
                  }).toList()),
            )
          : Scaffold(
              body: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.all(16),
                      child: const CircularProgressIndicator()))),
    );
  }
}
