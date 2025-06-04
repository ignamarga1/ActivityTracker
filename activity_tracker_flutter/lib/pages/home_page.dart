import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(DateFormat.yMMMMd().format(DateTime.now()))),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),
    );
  }
}
