import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width / 3,
    );
  }
}
