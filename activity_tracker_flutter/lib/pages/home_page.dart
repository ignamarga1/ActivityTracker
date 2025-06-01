import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text( DateFormat.yMMMMd().format(DateTime.now()))),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),
    );
  }
}
