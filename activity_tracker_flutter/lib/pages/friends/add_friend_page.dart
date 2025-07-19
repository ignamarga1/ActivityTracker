import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/friendship_request_service.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar solicitud de amistad')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,

      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // Information text
                Text(
                  "Escribe el nombre de usuario de la persona a la que quieres añadir a tu red de amistades",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 30),

                // Username
                TextFormField(
                  controller: usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El campo es obligatorio';
                    }
                    return null;
                  },
                  decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Nombre de usuario"),
                ),
                const SizedBox(height: 30),

                // Sent request button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),

                    child: const Text('Enviar solicitud', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        final receiverUsername = usernameController.text.trim();
                        final receiverUserId = await UserService().getUserIdByUsername(receiverUsername);

                        // Error control
                        if (receiverUserId == null) {
                          StdFluttertoast.show(
                            'No existe ningún usuario con ese nombre',
                            Toast.LENGTH_LONG,
                            ToastGravity.BOTTOM,
                          );
                        } else if (receiverUserId == user!.uid) {
                          StdFluttertoast.show(
                            'No puedes enviarte una solicitud a ti mismo',
                            Toast.LENGTH_LONG,
                            ToastGravity.BOTTOM,
                          );
                        } else if (await FriendshipRequestService().doesFriendshipRequestExist(
                          user.uid,
                          receiverUserId,
                        )) {
                          StdFluttertoast.show(
                            'Ya existe una solicitud de amistad con $receiverUsername',
                            Toast.LENGTH_LONG,
                            ToastGravity.BOTTOM,
                          );
                        } else {
                          // Creates the friendship request
                          await FriendshipRequestService().createFriendshipRequest(
                            senderUserId: user.uid,
                            receiverUserId: receiverUserId,
                            createdAt: Timestamp.now(),
                          );

                          // Pops the page
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }

                          // FlutterToast message
                          StdFluttertoast.show(
                            '¡Solicitud de amistad enviada con éxito a $receiverUsername!',
                            Toast.LENGTH_LONG,
                            ToastGravity.BOTTOM,
                          );
                        }
                      }
                    },
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
