import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/models/challenge_request.dart';
import 'package:activity_tracker_flutter/models/user.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:activity_tracker_flutter/services/challenge_request_service.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final pendingRequests = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Desafíos'), scrolledUnderElevation: 0),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width / 3,

      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Manage received challenge requests and create challenge buttons
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Received challenge requests
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(Icons.inbox_rounded),
                          iconSize: 35,
                          tooltip: 'Solicitudes recibidas',
                          onPressed: () {
                            setState(() {
                              Navigator.pushNamed(context, '/challengeRequests');
                            });
                          },
                        ),

                        // Stream to get the current number of requests and show in the icon
                        StreamBuilder<List<ChallengeRequest>>(
                          stream: ChallengeRequestService().getUserReceivedChallengeRequests(user!.uid),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox.shrink();

                            final pendingRequests = snapshot.data!
                                .where((request) => request.status == RequestStatus.pending)
                                .length;

                            if (pendingRequests == 0) return const SizedBox.shrink();

                            return Positioned(
                              top: -2,
                              right: -6,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                margin: const EdgeInsets.only(bottom: 5, right: 5),
                                child: Text(
                                  pendingRequests > 9 ? '9+' : '$pendingRequests',
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

                    // Create challenge request
                    IconButton(
                      icon: Icon(Icons.post_add_rounded),
                      iconSize: 35,
                      tooltip: 'Enviar desafío',
                      onPressed: () {
                        setState(() {
                          Navigator.pushNamed(context, '/sendChallenge');
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder<List<ChallengeRequest>>(
                stream: ChallengeRequestService().getUserChallenges(user.uid),
                builder: (context, snapshot) {
                  // Waiting for the accepted challenge list with circular progress indicator
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No has aceptado ninguna solicitud de desafío"));
                  }

                  final allChallengeRequests = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    itemCount: allChallengeRequests.length,
                    itemBuilder: (context, index) {
                      final challengeRequest = allChallengeRequests[index];

                      return StreamBuilder<AppUser?>(
                        stream: UserService().getUserById(challengeRequest.senderUserId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            // return const Center(child: CircularProgressIndicator());
                            return const Center();
                          }

                          final senderUser = snapshot.data;

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

                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),

                              // Profile picture
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

                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    senderUser.nickname,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text('@${senderUser.username}', overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 5),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(getStatusLabel(challengeRequest.status)),
                                  Text(DateFormat('dd-MM-yyyy (HH:mm)').format(challengeRequest.createdAt.toDate())),
                                ],
                              ),

                              // Activity content (visible when expanded)
                              children: [
                                StreamBuilder<Activity>(
                                  stream: ActivityService().getActivityById(challengeRequest.challengeActivityId),
                                  builder: (context, activitySnapshot) {
                                    if (activitySnapshot.connectionState == ConnectionState.waiting) {
                                      return const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text("Cargando actividad..."),
                                      );
                                    }

                                    if (!activitySnapshot.hasData) {
                                      return const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text("No se encontró la actividad."),
                                      );
                                    }

                                    final activity = activitySnapshot.data!;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Title
                                        Text(
                                          activity.title,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                        const SizedBox(height: 10),

                                        if (activity.description!.isNotEmpty)
                                          ActivityUtils().buildInfoRow('Descripción:', activity.description!),
                                        ActivityUtils().buildCategoryRow('Categoría:', activity.category),

                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ActivityUtils().buildInfoRow(
                                              'Tipo de hito:',
                                              ActivityUtils().getDetailedMilestoneLabel(activity.milestone),
                                            ),
                                            if (activity.milestone == MilestoneType.quantity) ...[
                                              ActivityUtils().buildInfoRow('Cantidad:', activity.quantity.toString()),
                                              ActivityUtils().buildInfoRow(
                                                'Unidad de medida:',
                                                activity.measurementUnit.toString(),
                                              ),
                                            ],
                                            if (activity.milestone == MilestoneType.timed)
                                              ActivityUtils().buildInfoRow(
                                                'Tiempo:',
                                                ActivityUtils().formatTime(
                                                  activity.durationHours!,
                                                  activity.durationMinutes!,
                                                  activity.durationSeconds!,
                                                ),
                                              ),
                                          ],
                                        ),

                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ActivityUtils().buildInfoRow(
                                              'Se repite:',
                                              ActivityUtils().getDetailedFrequencyLabel(activity.frequency),
                                            ),
                                            if (activity.frequency == FrequencyType.specificDayWeek &&
                                                activity.frequencyDaysOfWeek!.isNotEmpty)
                                              ActivityUtils().buildInfoRow(
                                                'Días de la semana:',
                                                ActivityUtils().formatWeekDays(activity.frequencyDaysOfWeek!),
                                              ),
                                            if (activity.frequency == FrequencyType.specificDayMonth &&
                                                activity.frequencyDaysOfMonth!.isNotEmpty)
                                              ActivityUtils().buildInfoRow(
                                                'Días del mes:',
                                                ActivityUtils().formatMonthDays(activity.frequencyDaysOfMonth!),
                                              ),
                                          ],
                                        ),

                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ActivityUtils().buildInfoRow(
                                              'Notificación:',
                                              activity.reminder ? 'Activada' : 'Desactivada',
                                            ),

                                            if (activity.reminder)
                                              ActivityUtils().buildInfoRow('Hora:', activity.reminderTime!),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
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

// Function that returns the request's label
String getStatusLabel(RequestStatus status) {
  return {
        RequestStatus.pending: "Pendiente de confirmación",
        RequestStatus.accepted: "Aceptada",
        RequestStatus.rejected: "Rechazada",
      }[status] ??
      "Desconocido";
}
