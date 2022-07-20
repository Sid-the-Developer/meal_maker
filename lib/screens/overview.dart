import 'package:flutter/material.dart';
import 'package:meal_planner/screens/browse.dart';
import 'package:meal_planner/widgets/recipe.dart';
import 'package:meal_planner/widgets/recipe_table.dart';
import 'package:mysql1/mysql1.dart';

final GlobalKey<FormState> _recipeKey = GlobalKey();
bool chef = false;
TabController? _tabController;

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage>
    with TickerProviderStateMixin {
  final GlobalKey<NavigatorState> _tab1Key = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _tab2Key = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _tab3Key = GlobalKey<NavigatorState>();
  int keyCount = 0;
  late final List<GlobalKey<NavigatorState>> _tabKeys = [_tab1Key, _tab2Key, _tab3Key];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      chef = (await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Home Selection'),
              children: [
                SimpleDialogOption(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(false),
                    child: const Text('Contributor')),
                SimpleDialogOption(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(true),
                    child: const Text('Chef'))
              ],
            );
          }))!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text('${chef ? 'Chef' : 'Contributor'} Home'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () => setState(() => chef = !chef),
                icon: const Icon(Icons.change_circle_outlined)),
            IconButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                icon: const Icon(Icons.logout_outlined))
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(chef ? 'Grocery Runs' : 'Write Recipe'),
              ),
              const Tab(
                child: Text('Browse Recipes'),
              ),
              Tab(
                child: Text('My ${chef ? 'Products' : 'Recipes'}'),
              )
            ],
          ),
        ),
        body: TabBarView(
            controller: _tabController,
            children: [
              Visibility(
                visible: chef,
                replacement: Recipe(
                  formKey: _recipeKey,
                  chef: true,
                ),
                child: Center(child: Text('Grocery Runs')),
              ),
              const Center(child: BrowseRecipes()),
              //TODO implement table view of data
              Visibility(
                  visible: chef,
                  replacement: const Center(child: RecipeTable()),
                  child: const Center(child: Text('My Products'))),
            ].map((tab) {
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
            }).toList()));
  }
}
