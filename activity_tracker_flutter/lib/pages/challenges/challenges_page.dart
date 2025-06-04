import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:flutter/material.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Desafíos')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),
    );
  }
}
