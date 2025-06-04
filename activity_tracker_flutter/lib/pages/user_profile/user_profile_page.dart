import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/auth_service.dart';
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
      drawer: const HomeDrawer(),

      // User data
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Cargando datos...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Profile picture
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: user.profilePictureURL != ''
                        ? NetworkImage(user.profilePictureURL!)
                        : null,
                    backgroundColor: Colors.grey.shade700,
                    child: user.profilePictureURL == ''
                        ? const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Username
                  Text(
                    '@${user.username}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // User Data section
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Mis datos',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nickname
                      Text.rich(
                        TextSpan(
                          text: 'Apodo: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: user.nickname,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Email
                      Text.rich(
                        TextSpan(
                          text: 'Correo electrónico: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: user.email,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Account createdDate
                      Text.rich(
                        TextSpan(
                          text: 'Fecha de creación: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: DateFormat(
                                'd/M/y, HH:mm',
                              ).format(user.createdAt.toDate()),
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // User Statistics section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mis estadísticas',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 280),

                  // Delete account button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      child: const Text(
                        'Eliminar cuenta',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                                    insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 24,
                                    ),
                                    titlePadding: const EdgeInsets.only(
                                      top: 16,
                                      left: 24,
                                      right: 8,
                                    ),

                                    // Title and close button
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Eliminar cuenta',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ],
                                    ),

                                    // Information and textField
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Esta acción es permanente.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Toda tu información será eliminada de forma permanente y no se podrá recuperar.',
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Introduce tu contraseña para confirmar la eliminación de tu cuenta:',
                                        ),
                                        SizedBox(height: 20),

                                        TextFormField(
                                          controller: passwordController,
                                          obscureText: isObscuredPassword,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
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
                                                  isObscuredPassword =
                                                      !isObscuredPassword;
                                                });
                                              },
                                              icon: isObscuredPassword
                                                  ? const Icon(
                                                      Icons.visibility_off,
                                                    )
                                                  : const Icon(
                                                      Icons.visibility,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Actions (just the confirm button as the close is next to title)
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          if (formKey.currentState!
                                              .validate()) {
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
            ),
    );
  }
}
