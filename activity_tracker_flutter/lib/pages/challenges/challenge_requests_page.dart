import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/models/challenge_request.dart';
import 'package:activity_tracker_flutter/models/user.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:activity_tracker_flutter/services/challenge_request_service.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChallengeRequestsPage extends StatefulWidget {
  const ChallengeRequestsPage({super.key});

  @override
  State<ChallengeRequestsPage> createState() => _ChallengeRequestsPageState();
}

class _ChallengeRequestsPageState extends State<ChallengeRequestsPage> with TickerProviderStateMixin {
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
        title: const Text('Solicitudes de desafíos'),
        bottom: TabBar(
          controller: tabBarController,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'Recibidos', icon: Icon(Icons.call_received_rounded)),
            Tab(text: 'Enviados', icon: Icon(Icons.call_made_rounded)),
          ],
        ),
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,

      body: TabBarView(
        controller: tabBarController,
        children: [_buildReceivedChallengesRequests(context, user!), _buildSentChallengesRequests(context, user)],
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

Widget _buildReceivedChallengesRequests(BuildContext context, AppUser user) {
  return GestureDetector(
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    behavior: HitTestBehavior.translucent,
    child: Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChallengeRequest>>(
            stream: ChallengeRequestService().getUserReceivedChallengeRequests(user.uid),
            builder: (context, snapshot) {
              // Waiting for the challenge requests list with circular progress indicator
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No has recibido ninguna solicitud de desafío"));
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

                      final senderNickname = senderUser?.nickname ?? 'Desconocido';
                      final senderUsername = senderUser?.username ?? 'desconocido';
                      final senderProfilePictureURL = senderUser?.profilePictureURL;

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
                                senderProfilePictureURL != null && senderProfilePictureURL.isNotEmpty
                                ? NetworkImage(senderProfilePictureURL)
                                : null,
                            backgroundColor: Colors.grey.shade600,
                            child: senderProfilePictureURL == null || senderProfilePictureURL.isEmpty
                                ? const Icon(Icons.person_rounded, color: Colors.white)
                                : null,
                          ),

                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                senderNickname,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('@$senderUsername', overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(getStatusLabel(challengeRequest.status)),
                              Text(DateFormat('dd-MM-yyyy (HH:mm)').format(challengeRequest.createdAt.toDate())),
                              if (challengeRequest.status == RequestStatus.pending) ...[
                                const Text(
                                  'Pulse para ver la actividad',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ),

                          // Accept and reject buttons
                          trailing: challengeRequest.status == RequestStatus.pending
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_rounded, color: Colors.green),
                                      tooltip: 'Aceptar',
                                      onPressed: () async {
                                        final activity = await ActivityService().getActivityByIdOnce(
                                          challengeRequest.challengeActivityId,
                                        );

                                        if (activity == null) {
                                          StdFluttertoast.show(
                                            'No se pudo obtener la actividad',
                                            Toast.LENGTH_LONG,
                                            ToastGravity.BOTTOM,
                                          );
                                          return;
                                        }
                                        ActivityService().createActivity(
                                          userId: user.uid,
                                          title: activity.title,
                                          description: activity.description,
                                          type: ActivityType.challenge,
                                          category: activity.category,
                                          milestone: activity.milestone,
                                          quantity: activity.quantity,
                                          measurementUnit: activity.measurementUnit,
                                          durationHours: activity.durationHours,
                                          durationMinutes: activity.durationMinutes,
                                          durationSeconds: activity.durationSeconds,
                                          frequency: activity.frequency,
                                          frequencyDaysOfWeek: activity.frequencyDaysOfWeek,
                                          frequencyDaysOfMonth: activity.frequencyDaysOfMonth,
                                          reminder: activity.reminder,
                                          reminderTime: activity.reminderTime,
                                          createdAt: Timestamp.now(),
                                        );

                                        ChallengeRequestService().updateChallengeRequest(
                                          id: challengeRequest.id,
                                          status: RequestStatus.accepted,
                                        );

                                        StdFluttertoast.show(
                                          'Has aceptado la solicitud de @$senderUsername',
                                          Toast.LENGTH_LONG,
                                          ToastGravity.BOTTOM,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.clear_rounded, color: Colors.red),
                                      tooltip: 'Rechazar',
                                      onPressed: () {
                                        ChallengeRequestService().updateChallengeRequest(
                                          id: challengeRequest.id,
                                          status: RequestStatus.rejected,
                                        );

                                        StdFluttertoast.show(
                                          'Has rechazado la solicitud de @$senderUsername',
                                          Toast.LENGTH_LONG,
                                          ToastGravity.BOTTOM,
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : null,

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
  );
}

Widget _buildSentChallengesRequests(BuildContext context, AppUser user) {
  return GestureDetector(
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    behavior: HitTestBehavior.translucent,
    child: Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChallengeRequest>>(
            stream: ChallengeRequestService().getUserSentChallengeRequests(user.uid),
            builder: (context, snapshot) {
              // Waiting for the challenge requests list with circular progress indicator
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No has enviado ninguna solicitud de desafío"));
              }

              final allChallengeRequests = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                itemCount: allChallengeRequests.length,
                itemBuilder: (context, index) {
                  final challengeRequest = allChallengeRequests[index];

                  return StreamBuilder<AppUser?>(
                    stream: UserService().getUserById(challengeRequest.receiverUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // return const Center(child: CircularProgressIndicator());
                        return const Center();
                      }

                      final receiverUser = snapshot.data;

                      final receiverNickname = receiverUser?.nickname ?? 'Desconocido';
                      final receiverUsername = receiverUser?.username ?? 'desconocido';
                      final receiverProfilePictureURL = receiverUser?.profilePictureURL;

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
                                receiverProfilePictureURL != null && receiverProfilePictureURL.isNotEmpty
                                ? NetworkImage(receiverProfilePictureURL)
                                : null,
                            backgroundColor: Colors.grey.shade600,
                            child: receiverProfilePictureURL == null || receiverProfilePictureURL.isEmpty
                                ? const Icon(Icons.person_rounded, color: Colors.white)
                                : null,
                          ),

                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                receiverNickname,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('@$receiverUsername', overflow: TextOverflow.ellipsis),
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
  );
}
