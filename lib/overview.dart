import 'package:flutter/material.dart';
import 'package:meal_planner/login.dart';
import 'package:mysql1/mysql1.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage>
    with TickerProviderStateMixin {
  bool chef = false;
  late final TabController _controller = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) async {chef = (await showDialog<bool>(
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
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(true), child: const Text('Chef'))
              ],
          );
          }
        ))!;}
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${chef ? 'Chef' : 'Contributor'} Home'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () => setState(() => chef = !chef),
              icon: const Icon(Icons.change_circle_outlined)),
          IconButton(
              onPressed: () => Navigator.popUntil(
                  context, (route) => route.isFirst),
              icon: const Icon(Icons.logout_outlined))
        ],
        bottom: TabBar(
          controller: _controller,
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
      body: TabBarView(controller: _controller, children: [
        Visibility(visible: chef,child: Center(child: Text(chef ? 'Grocery Runs' : 'Write Recipe')),),
        const Center(child: Text('Browse Recipes')), //TODO implement table view of data
        Visibility(visible: chef, child: Center(child: Text('My ${chef ? 'Reviews' : 'Recipes'}')))
      ]),
    );
  }
}
