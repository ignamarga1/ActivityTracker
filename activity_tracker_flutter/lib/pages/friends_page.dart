import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amigos')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),
    );
  }
}
