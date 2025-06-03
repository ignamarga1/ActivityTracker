import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),
    );
  }
}
