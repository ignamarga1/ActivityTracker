import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/models/friendship_request.dart';
import 'package:activity_tracker_flutter/models/user.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:activity_tracker_flutter/services/challenge_request_service.dart';
import 'package:activity_tracker_flutter/services/friendship_request_service.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class SendChallengePage extends StatefulWidget {
  const SendChallengePage({super.key});

  @override
  State<SendChallengePage> createState() => _SendChallengePageState();
}

class _SendChallengePageState extends State<SendChallengePage> {
  AppUser? preselectedFriend; // Only used when coming from the friends page
  String? _selectedFriendId;
  String? _selectedActivityId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args['preselectedFriend'] != null) {
      preselectedFriend = args['preselectedFriend'] as AppUser;
      _selectedFriendId ??= preselectedFriend!.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar solicitud de desafío'), scrolledUnderElevation: 0),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,

      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // Information text (changes if you have preselected a friend in the friends page)
                preselectedFriend != null
                    ? Text(
                        "Selecciona una de tus actividades para enviarla a tu amigo a modo de desafío",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                      )
                    : Text(
                        "Selecciona a un usuario de tu lista de amigos a quien enviarle una de tus actividades a modo de desafío",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                      ),
                const SizedBox(height: 30),

                // Select friend (shows the preselected user or a dropdown to select a friend)
                preselectedFriend != null
                    ? Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundImage: preselectedFriend!.profilePictureURL != null
                                  ? NetworkImage(preselectedFriend!.profilePictureURL!)
                                  : null,
                              backgroundColor: Colors.grey.shade600,
                              child: preselectedFriend!.profilePictureURL == null
                                  ? const Icon(Icons.person_rounded, color: Colors.white, size: 30)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(preselectedFriend!.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('@${preselectedFriend!.username}'),
                              ],
                            ),
                          ],
                        ),
                      )
                    : StreamBuilder<List<FriendshipRequest>>(
                        stream: FriendshipRequestService().getUserFriends(user!.uid),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final friendships = snapshot.data!;
                          if (friendships.isEmpty) {
                            return const Text("No tienes añadidos amigos a los que enviarles un desafío");
                          }

                          final friendIds = friendships.map((request) {
                            return request.senderUserId == user.uid ? request.receiverUserId : request.senderUserId;
                          }).toList();

                          return FutureBuilder<List<AppUser?>>(
                            future: Future.wait(friendIds.map((id) => UserService().getUserById(id).first)),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return const CircularProgressIndicator();
                              }

                              final users = userSnapshot.data!.whereType<AppUser>().toList();

                              // Dropdown menu with the friends
                              return DropdownMenu<String?>(
                                key: ValueKey(_selectedFriendId),
                                initialSelection: _selectedFriendId,
                                label: const Text('Selecciona un amigo'),
                                width: MediaQuery.of(context).size.width - 50,
                                menuStyle: MenuStyle(
                                  maximumSize: WidgetStateProperty.all(const Size(double.infinity, 150)),
                                ),

                                // Entries
                                dropdownMenuEntries: users.map((friend) {
                                  return DropdownMenuEntry<String?>(
                                    value: friend.uid,
                                    label: friend.username,
                                    labelWidget: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundImage:
                                              friend.profilePictureURL != null && friend.profilePictureURL!.isNotEmpty
                                              ? NetworkImage(friend.profilePictureURL!)
                                              : null,
                                          backgroundColor: Colors.grey.shade600,
                                          child: friend.profilePictureURL == null || friend.profilePictureURL!.isEmpty
                                              ? const Icon(Icons.person_rounded, color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                friend.nickname,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text('@${friend.username}', overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),

                                onSelected: (String? selectedId) {
                                  setState(() {
                                    _selectedFriendId = selectedId;
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                const SizedBox(height: 30),

                // Select activity
                StreamBuilder<List<Activity>>(
                  stream: ActivityService().getUserCustomActivitiesStream(user!.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final activities = snapshot.data!;
                    if (activities.isEmpty) {
                      return const Text("No has creado ninguna actividad");
                    }

                    return DropdownMenu<String?>(
                      key: ValueKey(_selectedActivityId),
                      initialSelection: _selectedActivityId,
                      label: const Text('Selecciona una actividad'),
                      width: MediaQuery.of(context).size.width - 50,
                      menuStyle: MenuStyle(maximumSize: WidgetStateProperty.all(const Size(double.infinity, 160))),

                      // Entries
                      dropdownMenuEntries: activities.map((activity) {
                        return DropdownMenuEntry<String?>(
                          value: activity.id,
                          label: activity.title,
                          labelWidget: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),

                              Text(
                                "${ActivityUtils().getMilestoneLabel(activity.milestone)} • ${ActivityUtils().getCategoryLabel(activity.category)}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onSelected: (String? selectedId) {
                        setState(() {
                          _selectedActivityId = selectedId;
                        });
                      },
                    );
                  },
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
                      // Error control
                      if (_selectedFriendId == null || _selectedFriendId!.isEmpty) {
                        StdFluttertoast.show(
                          'No has seleccionado a nadie a quien enviarle el desafío',
                          Toast.LENGTH_LONG,
                          ToastGravity.BOTTOM,
                        );
                        return;
                      }

                      if (_selectedActivityId == null || _selectedActivityId!.isEmpty) {
                        StdFluttertoast.show(
                          'No has seleccionado ninguna actividad para el desafío',
                          Toast.LENGTH_LONG,
                          ToastGravity.BOTTOM,
                        );
                        return;
                      }

                      final selectedFriend = await UserService().getUserById(_selectedFriendId!).first;

                      if (await ChallengeRequestService().doesChallengeRequestExist(
                        user.uid,
                        _selectedFriendId!,
                        _selectedActivityId!,
                      )) {
                        StdFluttertoast.show(
                          'Ya has enviado esa actividad en otra solicitud de desafío a @${selectedFriend!.username}',
                          Toast.LENGTH_LONG,
                          ToastGravity.BOTTOM,
                        );
                      } else {
                        // Creates the challenge request
                        ChallengeRequestService().createChallengeRequest(
                          senderUserId: user.uid,
                          receiverUserId: _selectedFriendId!,
                          challengeActivityId: _selectedActivityId!,
                          createdAt: Timestamp.now(),
                        );

                        // Pops the page
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }

                        // FlutterToast message
                        StdFluttertoast.show(
                          '¡Solicitud de desafío enviada con éxito a @${selectedFriend!.username}!',
                          Toast.LENGTH_LONG,
                          ToastGravity.BOTTOM,
                        );
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
