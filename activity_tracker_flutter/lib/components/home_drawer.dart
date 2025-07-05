import 'package:activity_tracker_flutter/components/drawer_header.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:activity_tracker_flutter/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'drawer_tile.dart'; // si lo separas en otro archivo

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
    final iconSize = 30.0;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    final user = Provider.of<UserProvider>(context).user;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // DRAWER HEADER
          ProfileCardHeader(
            profileImageUrl: user!.profilePictureURL,
            username: user.username,
            nickname: user.nickname,
          ),
          
          // DRAWER OPTIONS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 10),
              children: [
                // Home
                DrawerTile(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  iconSize: iconSize,
                  textStyle: textStyle,
                  selected: currentRoute == '/',
                  onTap: () {
                    if (currentRoute == '/') {
                      Navigator.of(context).pop();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    }
                  },
                ),

                // Profile
                DrawerTile(
                  icon: Icons.person,
                  label: 'Perfil',
                  iconSize: iconSize,
                  textStyle: textStyle,
                  selected: currentRoute == '/userProfile',
                  onTap: () {
                    if (currentRoute != '/userProfile') {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/userProfile',
                        (route) => false,
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),

                // Friends
                DrawerTile(
                  icon: Icons.groups,
                  label: 'Amigos',
                  iconSize: iconSize,
                  textStyle: textStyle,
                  selected: currentRoute == '/friends',
                  onTap: () {
                    if (currentRoute != '/friends') {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/friends',
                        (route) => false,
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                DrawerTile(
                  icon: Icons.mail,
                  label: 'Mensajes',
                  iconSize: iconSize,
                  textStyle: textStyle,
                  selected: currentRoute == '/messages',
                  onTap: () {
                    if (currentRoute != '/messages') {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/messages',
                        (route) => false,
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                DrawerTile(
                  icon: Icons.shield,
                  label: 'Desafíos',
                  iconSize: iconSize,
                  textStyle: textStyle,
                  selected: currentRoute == '/challenges',
                  onTap: () {
                    if (currentRoute != '/challenges') {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/challenges',
                        (route) => false,
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),

          const Divider(color: Colors.grey),

          // DRAWER BOTTOM OPTIONS
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                DrawerTile(
                  icon: Icons.settings,
                  label: 'Ajustes',
                  iconSize: iconSize,
                  textStyle: textStyle,
                  selected: currentRoute == '/settings',
                  onTap: () {
                    if (currentRoute != '/settings') {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/settings',
                        (route) => false,
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                DrawerTile(
                  icon: Icons.logout_outlined,
                  label: 'Cerrar sesión',
                  iconSize: iconSize,
                  textStyle: textStyle,
                  selected: false,
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
