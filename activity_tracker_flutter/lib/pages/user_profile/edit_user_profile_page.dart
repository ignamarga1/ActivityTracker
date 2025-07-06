import 'dart:io';

import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/cloudinary_service.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditUserProfilePage extends StatefulWidget {
  const EditUserProfilePage({super.key});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final nickNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  bool isDialogShown = false;

  // Selects an image from the phones gallery
  Future<String?> selectImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image == null) return null;

    return image.path;
  }

  // Lets the user take a photo
  Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (photo == null) return null;

    return photo.path;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      // Appbar with title and edit button
      appBar: AppBar(title: const Text('Edición del perfil')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,

      // User data
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: user == null
            ? Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile picture
                        Stack(
                          children: [
                            // Photo
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _selectedImagePath != null
                                  ? FileImage(File(_selectedImagePath!))
                                  : (user.profilePictureURL != ''
                                        ? NetworkImage(user.profilePictureURL!)
                                        : null),
                              backgroundColor: Colors.grey.shade700,
                              child:
                                  (_selectedImagePath == null &&
                                      user.profilePictureURL == '')
                                  ? const Icon(Icons.person, size: 80)
                                  : null,
                            ),

                            // Edit image button
                            Positioned(
                              bottom: -4,
                              right: 2,
                              child: GestureDetector(
                                onTap: () {
                                  // Bottom sheet modal for image option
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Center(
                                              child: Container(
                                                width: 40,
                                                height: 4,
                                                margin: const EdgeInsets.only(
                                                  bottom: 15,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade700,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 15),

                                            // Options: library and camera
                                            ListTile(
                                              leading: const Icon(
                                                Icons.photo_library,
                                              ),
                                              title: const Text(
                                                'Elegir de la galería',
                                              ),
                                              onTap: () async {
                                                final path =
                                                    await selectImage();
                                                if (path != null) {
                                                  setState(() {
                                                    _selectedImagePath = path;
                                                  });
                                                }
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
                                              },
                                            ),

                                            ListTile(
                                              leading: const Icon(
                                                Icons.photo_camera,
                                              ),
                                              title: const Text(
                                                'Hacer una foto',
                                              ),
                                              onTap: () async {
                                                final path = await takePhoto();
                                                if (path != null) {
                                                  setState(() {
                                                    _selectedImagePath = path;
                                                  });
                                                }
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },

                                // Camera button
                                child: ClipOval(
                                  child: Container(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    padding: EdgeInsets.all(4),
                                    child: ClipOval(
                                      child: Container(
                                        color: Colors.blue,
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.photo_camera,
                                          size: 18,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // New nickname textfield
                        TextFormField(
                          controller: nickNameController,
                          obscureText: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Nuevo apodo",
                          ),
                        ),

                        const Spacer(),

                        // Save changes button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),

                            child: const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            onPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              String? imageUrl;
                              final String newNickname = nickNameController.text
                                  .trim();
                              final bool isNickNameChanged =
                                  newNickname.isNotEmpty &&
                                  (newNickname != user.nickname);
                              final bool isImageChanged =
                                  _selectedImagePath != null;

                              // Checks if there are any changes in case the user presses the button (for not showing the Fluttertoast)
                              if (!isNickNameChanged && !isImageChanged) {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  return;
                                }
                              }

                              // Uploads image to Cloudinary

                              if (_selectedImagePath != null) {
                                // Loading dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );
                                isDialogShown = true;

                                final uploadedUrl = await CloudinaryService()
                                    .uploadImageToCloudinary(
                                      File(_selectedImagePath!),
                                    );
                                if (uploadedUrl == null) {
                                  // Checks if the photo dialog has been used and closes it
                                  if (isDialogShown && context.mounted) {
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                  StdFluttertoast.show(
                                    'No se ha podido subir la imagen. Inténtalo de nuevo',
                                    Toast.LENGTH_LONG,
                                    ToastGravity.BOTTOM,
                                  );
                                  return;
                                }
                                imageUrl = uploadedUrl;
                              }

                              // Updates user nickname and imageUrl
                              await UserService().updateUserDocument(
                                newNickname: newNickname,
                                newImageUrl: imageUrl,
                              );

                              // Pops loading if active
                              if (isDialogShown && context.mounted) {
                                Navigator.of(context).pop();
                              }

                              // Pops the edit page
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              // FlutterToast message
                              StdFluttertoast.show(
                                '¡Perfil actualizado con éxito!',
                                Toast.LENGTH_LONG,
                                ToastGravity.BOTTOM,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
