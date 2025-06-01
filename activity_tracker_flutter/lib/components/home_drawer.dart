import 'package:activity_tracker_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
    final iconSize = 30.0;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Drawer header
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(color: Colors.grey.shade800),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Activity Tracker',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: null,
                      backgroundColor: Colors.grey.shade700,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),

                    const SizedBox(width: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'nombreDeUsuario',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          '@apodo',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),

          // Home tile
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 40),
              children: [
                // Home
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 5),
                  child: ListTile(
                    leading: Icon(Icons.home_rounded, size: iconSize),
                    title: Text('Inicio', style: textStyle),
                    onTap: () {
                      Navigator.pushNamed(context, '/');
                    },
                  ),
                ),

                // Profile tile
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 5),
                  child: ListTile(
                    leading: Icon(Icons.person, size: iconSize),
                    title: Text('Perfil', style: textStyle),
                    onTap: () {},
                  ),
                ),

                // Friends tile
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 5),
                  child: ListTile(
                    leading: Icon(Icons.groups, size: iconSize),
                    title: Text('Amigos', style: textStyle),
                    onTap: () {},
                  ),
                ),

                // Messages tile
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 5),
                  child: ListTile(
                    leading: Icon(Icons.mail, size: iconSize),
                    title: Text('Mensajes', style: textStyle),
                    onTap: () {},
                  ),
                ),

                // Challenges tile
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 5),
                  child: ListTile(
                    leading: Icon(Icons.shield, size: iconSize),
                    title: Text('Desafíos', style: textStyle),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.grey),

          Padding(
            padding: const EdgeInsets.only(left: 25, top: 5),
            child: Column(
              children: [
                // Settings button
                ListTile(
                  leading: Icon(Icons.settings, size: iconSize),
                  title: Text('Ajustes', style: textStyle),
                  onTap: () {},
                ),

                // Log out button
                ListTile(
                  leading: Icon(Icons.logout_outlined, size: iconSize),
                  title: Text('Cerrar sesión', style: textStyle),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            '¿Estás seguro de que deseas cerrar sesión?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                AuthService().logOut(context: context);
                              },
                              child: const Text('Sí'),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('No'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
