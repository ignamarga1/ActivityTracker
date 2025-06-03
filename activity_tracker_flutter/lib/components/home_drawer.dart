import 'package:activity_tracker_flutter/models/user.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:activity_tracker_flutter/services/auth_service.dart';
import 'drawer_tile.dart'; // si lo separas en otro archivo

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
    final iconSize = 30.0;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // DRAWER HEADER
          FutureBuilder<AppUser?>(
            // Get current user data
            future: UserService().getCurrentUserData(),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(color: Colors.grey.shade800),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                return DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(color: Colors.grey.shade800),
                  child: Center(
                    child: Text(
                      'Usuario no encontrado',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              final user = asyncSnapshot.data!;

              // DRAWER HEADER
              return DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(color: Colors.grey.shade800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App name
                    Text(
                      'Activity Tracker',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // User profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              user.profilePictureURL != null &&
                                  user.profilePictureURL!.isNotEmpty
                              ? NetworkImage(user.profilePictureURL!)
                              : null,
                          backgroundColor: Colors.grey.shade700,
                          child:
                              (user.profilePictureURL == null ||
                                  user.profilePictureURL!.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${user.username}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              user.nickname,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
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
                      Navigator.pushNamed(context, '/userProfile');
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
                      Navigator.pushNamed(context, '/friends');
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),

                // Messages
                DrawerTile(
                  icon: Icons.mail,
                  label: 'Mensajes',
                  iconSize: iconSize,
                  textStyle: textStyle,
                  selected: currentRoute == '/messages',
                  onTap: () {
                    if (currentRoute != '/messages') {
                      Navigator.pushNamed(context, '/messages');
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),

                // Challenges
                DrawerTile(
                  icon: Icons.shield,
                  label: 'Desafíos',
                  iconSize: iconSize,
                  textStyle: textStyle,
                  selected: currentRoute == '/challenges',
                  onTap: () {
                    if (currentRoute != '/challenges') {
                      Navigator.pushNamed(context, '/challenges');
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
                      Navigator.pushNamed(context, '/settings');
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
