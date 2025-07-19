import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:activity_tracker_flutter/models/friendship_request.dart';
import 'package:activity_tracker_flutter/models/user.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/friendship_request_service.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final pendingRequests = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Amigos')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width / 3,

      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // Manage received friendship requests and Add friend buttons
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Received friendship requests
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(Icons.group_rounded),
                          iconSize: 35,
                          tooltip: 'Solicitudes recibidas',
                          onPressed: () {
                            setState(() {
                              Navigator.pushNamed(context, '/friendRequests');
                            });
                          },
                        ),

                        // Stream to get the current number of requests and show in the icon
                        StreamBuilder<List<FriendshipRequest>>(
                          stream: FriendshipRequestService().getUserReceivedFriendshipRequests(user!.uid),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox.shrink();

                            final pendingRequests = snapshot.data!
                                .where((request) => request.status == RequestStatus.pending)
                                .length;

                            if (pendingRequests == 0) return const SizedBox.shrink();

                            return Positioned(
                              top: -2,
                              right: -12,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                margin: const EdgeInsets.only(bottom: 5, right: 5),
                                child: Text(
                                  '$pendingRequests',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Add friend
                    IconButton(
                      icon: Icon(Icons.person_add_rounded),
                      iconSize: 35,
                      tooltip: 'Añadir amigo',
                      onPressed: () {
                        setState(() {
                          Navigator.pushNamed(context, '/addFriend');
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Friends list
            Expanded(
              child: StreamBuilder<List<FriendshipRequest>>(
                stream: FriendshipRequestService().getUserFriends(user.uid),
                builder: (context, snapshot) {
                  // Waiting for the frienship requests list with circular progress indicator
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No tienes a nadie añadido en tu red de amistades"));
                  }

                  final allFriendshipRequests = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    itemCount: allFriendshipRequests.length,
                    itemBuilder: (context, index) {
                      final friendshipRequest = allFriendshipRequests[index];
                      
                      // Makes sure we see our friends instead of us in the friends list
                      final otherUserId = friendshipRequest.senderUserId == user.uid
                          ? friendshipRequest.receiverUserId
                          : friendshipRequest.senderUserId;

                      return FutureBuilder<AppUser?>(
                        future: UserService().getUserById(otherUserId),
                        builder: (context, snapshot) {
                          // if (snapshot.connectionState == ConnectionState.waiting) {
                          //   return const Center(child: CircularProgressIndicator());
                          // }

                          final senderUser = snapshot.data;

                          if (senderUser == null) {
                            return const ListTile(title: Text("Usuario no encontrado"));
                          }
                          
                          // User information
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.grey.shade700, width: 2),
                            ),

                            // Profile picture
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              leading: CircleAvatar(
                                backgroundImage:
                                    senderUser.profilePictureURL != null && senderUser.profilePictureURL!.isNotEmpty
                                    ? NetworkImage(senderUser.profilePictureURL!)
                                    : null,
                                backgroundColor: Colors.grey.shade600,
                                child: senderUser.profilePictureURL == null || senderUser.profilePictureURL!.isEmpty
                                    ? const Icon(Icons.person_rounded, color: Colors.white)
                                    : null,
                              ),
                              title: Text(
                                '@${senderUser.username}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Messages, challenges and delete friend buttons
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chat_rounded),
                                    tooltip: 'Enviar mensaje',
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.emoji_events_rounded),
                                    tooltip: 'Mandar desafío',
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.person_remove_rounded),
                                    tooltip: 'Eliminar amigo',
                                    onPressed: () {},
                                  ),
                                ],
                              ),
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
