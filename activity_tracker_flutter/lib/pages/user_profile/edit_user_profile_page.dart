import 'dart:io';

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

  // Methods
  Future<String?> selectImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image == null) return null;

    return image.path;
  }

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
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

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
                              ? const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.white,
                                )
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
                                        Text(
                                          'Selecciona una opción',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),

                                        const SizedBox(height: 20),

                                        // Options: library and camera
                                        ListTile(
                                          leading: const Icon(
                                            Icons.photo_library,
                                          ),
                                          title: const Text(
                                            'Elegir de la galería',
                                          ),
                                          onTap: () async {
                                            final path = await selectImage();
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
                                          title: const Text('Hacer una foto'),
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

                            // Button
                            child: ClipOval(
                              child: Container(
                                color: Theme.of(context).colorScheme.surface,
                                padding: EdgeInsets.all(4),
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.blue,
                                    padding: EdgeInsets.all(6),
                                    child: Icon(Icons.photo_camera, size: 18),
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

                    const SizedBox(height: 50),

                    // Save changes button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.all(20),
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
                            final uploadedUrl = await CloudinaryService()
                                .uploadImageToCloudinary(
                                  File(_selectedImagePath!),
                                );
                            if (uploadedUrl == null) {
                              Fluttertoast.showToast(
                                msg:
                                    'No se ha podido subir la imagen. Inténtalo de nuevo',
                                toastLength: Toast.LENGTH_LONG,
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

                          // Refreshes the user data to show the latest changes
                          if (context.mounted) {
                            await Provider.of<UserProvider>(
                              context,
                              listen: false,
                            ).refreshUser();
                          }

                          // Pop and Fluttertoast success message
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                          Fluttertoast.showToast(
                            msg: '¡Perfil actualizado con éxito!',
                            toastLength: Toast.LENGTH_LONG,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
