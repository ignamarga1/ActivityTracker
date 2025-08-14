import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:activity_tracker_flutter/services/auth_service.dart';
import 'package:activity_tracker_flutter/services/challenge_request_service.dart';
import 'package:activity_tracker_flutter/services/friendship_request_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      // Appbar with title and edit button
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar perfil',
            onPressed: () {
              Navigator.pushNamed(context, '/editUserProfile');
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,
      drawer: const HomeDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,

      // User data
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile picture
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: user.profilePictureURL != '' ? NetworkImage(user.profilePictureURL!) : null,
                        backgroundColor: Colors.grey.shade700,
                        child: user.profilePictureURL == ''
                            ? const Icon(Icons.person, size: 80, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Username
                      Text('@${user.username}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),

                      // User data section
                      const Text(
                        'Mis datos',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nickname
                          ActivityUtils().buildInfoRow('Apodo:', user.nickname),

                          // Email
                          ActivityUtils().buildInfoRow('Email:', user.email),

                          // Account createdDate
                          ActivityUtils().buildInfoRow('Fecha de unión:', DateFormat('dd/MM/yyyy, HH:mm').format(user.createdAt.toDate())),
                        ],
                      ),

                      // More user data
                      const SizedBox(height: 25),
                      const Text(
                        'Mis estadísticas',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Friends
                          buildInfoRowFromStream(
                            title: 'Número de amigos:',
                            stream: FriendshipRequestService().getUserFriends(user.uid),
                          ),

                          // Activities
                          buildInfoRowFromStream(
                            title: 'Número de actividades:',
                            stream: ActivityService().getUserActivitiesStream(user.uid),
                          ),

                          // Received challenges
                          buildInfoRowFromStream(
                            title: 'Número de desafíos recibidos:',
                            stream: ChallengeRequestService().getUserReceivedChallengeRequests(user.uid),
                          ),

                          // Sent challenges
                          buildInfoRowFromStream(
                            title: 'Número de desafíos enviados:',
                            stream: ChallengeRequestService().getUserSentChallengeRequests(user.uid),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Delete account button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),

                          child: const Text(
                            'Eliminar cuenta',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),

                          onPressed: () async {
                            final formKey = GlobalKey<FormState>();
                            var isObscuredPassword = true;

                            // Delete account dialog with textField for password
                            showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Form(
                                      key: formKey,
                                      child: AlertDialog(
                                        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                                        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 8),

                                        // Title and close button
                                        title: const Text(
                                          'Eliminar cuenta',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),

                                        // Information and textField
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Esta acción es permanente',
                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Toda tu información será eliminada de forma permanente y no se podrá recuperar.',
                                              textAlign: TextAlign.justify,
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Introduce tu contraseña para confirmar la eliminación de tu cuenta:',
                                              textAlign: TextAlign.justify,
                                            ),
                                            SizedBox(height: 30),

                                            TextFormField(
                                              controller: passwordController,
                                              obscureText: isObscuredPassword,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'El campo es obligatorio';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "Contraseña",
                                                suffixIcon: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isObscuredPassword = !isObscuredPassword;
                                                    });
                                                  },
                                                  icon: isObscuredPassword
                                                      ? const Icon(Icons.visibility_off)
                                                      : const Icon(Icons.visibility),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        actions: [
                                          TextButton(
                                            child: const Text('Cancelar'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),

                                          TextButton(
                                            onPressed: () {
                                              FocusManager.instance.primaryFocus?.unfocus();
                                              if (formKey.currentState!.validate()) {
                                                AuthService().deleteAccount(
                                                  context: context,
                                                  password: passwordController.text,
                                                );
                                              }
                                            },
                                            child: const Text('Confirmar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// Widget that uses buildInfoRow and converts the stream to get its length in a String
Widget buildInfoRowFromStream<T>({required String title, required Stream<List<T>> stream}) {
  return StreamBuilder<List<T>>(
    stream: stream,
    builder: (context, snapshot) {
      final count = snapshot.hasData ? snapshot.data!.length : 0;
      return ActivityUtils().buildInfoRow(title, count.toString());
    },
  );
}


