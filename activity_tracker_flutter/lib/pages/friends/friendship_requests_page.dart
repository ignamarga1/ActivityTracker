import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/models/friendship_request.dart';
import 'package:activity_tracker_flutter/models/user.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/friendship_request_service.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FriendshipRequestsPage extends StatefulWidget {
  const FriendshipRequestsPage({super.key});

  @override
  State<FriendshipRequestsPage> createState() => _FriendshipRequestsPageState();
}

class _FriendshipRequestsPageState extends State<FriendshipRequestsPage> with TickerProviderStateMixin {
  late final TabController tabBarController;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    super.dispose();
    tabBarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de amistad'),
        bottom: TabBar(
          controller: tabBarController,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'Recibidas', icon: Icon(Icons.call_received_rounded)),
            Tab(text: 'Enviadas', icon: Icon(Icons.call_made_rounded)),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,

      body: TabBarView(
        controller: tabBarController,
        children: [_buildReceivedFriendshipRequests(context, user!), _buildSentFriendshipRequests(context, user)],
      ),
    );
  }
}

// Function that returns the Milestone's label
String getStatusLabel(RequestStatus status) {
  return {
        RequestStatus.pending: "Pendiente de confirmación",
        RequestStatus.accepted: "Aceptada",
        RequestStatus.rejected: "Rechazada",
      }[status] ??
      "Desconocido";
}

Widget _buildReceivedFriendshipRequests(BuildContext context, AppUser user) {
  return GestureDetector(
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    behavior: HitTestBehavior.translucent,
    child: Column(
      children: [
        Expanded(
          child: StreamBuilder<List<FriendshipRequest>>(
            stream: FriendshipRequestService().getUserReceivedFriendshipRequests(user.uid),
            builder: (context, snapshot) {
              // Waiting for the frienship requests list with circular progress indicator
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No has recibido ninguna solicitud de amistad"));
              }

              final allFriendshipRequests = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                itemCount: allFriendshipRequests.length,
                itemBuilder: (context, index) {
                  final friendshipRequest = allFriendshipRequests[index];

                  return StreamBuilder<AppUser?>(
                    stream: UserService().getUserById(friendshipRequest.senderUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // return const Center(child: CircularProgressIndicator());
                        return const Center();
                      }

                      final senderUser = snapshot.data;

                      // if (senderUser == null) {
                      //   return const ListTile(title: Text("Usuario no encontrado"));
                      // }

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
                          leading: CircleAvatar(
                            backgroundImage:
                                senderUser!.profilePictureURL != null && senderUser.profilePictureURL!.isNotEmpty
                                ? NetworkImage(senderUser.profilePictureURL!)
                                : null,
                            backgroundColor: Colors.grey.shade600,
                            child: senderUser.profilePictureURL == null || senderUser.profilePictureURL!.isEmpty
                                ? const Icon(Icons.person_rounded, color: Colors.white)
                                : null,
                          ),
                          title: Text('@${senderUser.username}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(senderUser.nickname, overflow: TextOverflow.ellipsis),
                              Text(getStatusLabel(friendshipRequest.status)),
                              Text(DateFormat('dd-MM-yyyy (HH:mm)').format(friendshipRequest.createdAt.toDate())),
                            ],
                          ),

                          // Accept and reject buttons
                          trailing: friendshipRequest.status == RequestStatus.pending
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_rounded, color: Colors.green),
                                      tooltip: 'Aceptar',
                                      onPressed: () {
                                        FriendshipRequestService().updateFriendshipRequest(
                                          id: friendshipRequest.id,
                                          status: RequestStatus.accepted,
                                        );

                                        StdFluttertoast.show(
                                          'Has aceptado la solicitud de ${senderUser.username}',
                                          Toast.LENGTH_LONG,
                                          ToastGravity.BOTTOM,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.clear_rounded, color: Colors.red),
                                      tooltip: 'Rechazar',
                                      onPressed: () {
                                        FriendshipRequestService().updateFriendshipRequest(
                                          id: friendshipRequest.id,
                                          status: RequestStatus.rejected,
                                        );

                                        StdFluttertoast.show(
                                          'Has rechazado la solicitud de ${senderUser.username}',
                                          Toast.LENGTH_LONG,
                                          ToastGravity.BOTTOM,
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : null,
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
}

Widget _buildSentFriendshipRequests(BuildContext context, AppUser user) {
  return GestureDetector(
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    behavior: HitTestBehavior.translucent,
    child: Column(
      children: [
        Expanded(
          child: StreamBuilder<List<FriendshipRequest>>(
            stream: FriendshipRequestService().getUserSentFriendshipRequests(user.uid),
            builder: (context, snapshot) {
              // Waiting for the frienship requests list with circular progress indicator
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No has enviado ninguna solicitud de amistad"));
              }

              final allFriendshipRequests = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                itemCount: allFriendshipRequests.length,
                itemBuilder: (context, index) {
                  final friendshipRequest = allFriendshipRequests[index];

                  return StreamBuilder<AppUser?> (
                    stream: UserService().getUserById(friendshipRequest.receiverUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // return const Center(child: CircularProgressIndicator());
                        return const Center();
                      }

                      final receiverUser = snapshot.data;

                      // if (receiverUser == null) {
                      //   return const ListTile(title: Text("Usuario no encontrado"));
                      // }

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
                          leading: CircleAvatar(
                            backgroundImage:
                                receiverUser!.profilePictureURL != null && receiverUser.profilePictureURL!.isNotEmpty
                                ? NetworkImage(receiverUser.profilePictureURL!)
                                : null,
                            backgroundColor: Colors.grey.shade600,
                            child: receiverUser.profilePictureURL == null || receiverUser.profilePictureURL!.isEmpty
                                ? const Icon(Icons.person_rounded, color: Colors.white)
                                : null,
                          ),
                          title: Text('@${receiverUser.username}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(receiverUser.nickname, overflow: TextOverflow.ellipsis),
                              Text(getStatusLabel(friendshipRequest.status)),
                              Text(DateFormat('dd-MM-yyyy (HH:mm)').format(friendshipRequest.createdAt.toDate())),
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
  );
}
