import 'package:activity_tracker_flutter/components/activity_progress_calendar.dart';
import 'package:activity_tracker_flutter/components/activity_progress_chart.dart';
import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ActivityDetailsPage extends StatefulWidget {
  const ActivityDetailsPage({super.key});

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> with TickerProviderStateMixin {
  late final TabController tabBarController;
  String? activityId;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    super.dispose();
    tabBarController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    activityId = ModalRoute.of(context)!.settings.arguments as String;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Activity>(
      stream: ActivityService().getActivityById(activityId!),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('No se pudo cargar la actividad')));
        }

        final activity = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalles'),
            backgroundColor: Theme.of(context).colorScheme.surface,

            // TabBar
            bottom: TabBar(
              controller: tabBarController,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'Estadísticas', icon: Icon(Icons.bar_chart_rounded)),
                Tab(text: 'Información', icon: Icon(Icons.assignment)),
              ],
            ),

            // Edit button
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  Navigator.pushNamed(context, '/editActivity', arguments: activity);
                },
              ),
            ],
          ),

          // TabBar contents
          body: TabBarView(
            controller: tabBarController,
            children: [_buildStatisticsTab(context, activity), _buildDetailsTab(context, activity)],
          ),
        );
      },
    );
  }
}

// Widget that shows the statistics of the activity
Widget _buildStatisticsTab(BuildContext context, Activity activity) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ROW 1: Completion calendar
                const Text(
                  'Calendario de compleción',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 5),

                // Calendar
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey.shade700, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ActivityProgressCalendar(activity: activity),
                  ),
                ),
                const SizedBox(height: 25),

                // ROW 2: Streak info
                const Text(
                  'Racha',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Streak
                    Expanded(
                      child: Card(
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey.shade700, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Racha actual', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 30),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      '${activity.completionStreak}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Max streak
                    Expanded(
                      child: Card(
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey.shade700, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Máxima racha', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.military_tech, color: Colors.amberAccent, size: 30),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      '${activity.maxCompletionStreak}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // ROW 3: Streak info
                const Text(
                  'Gráfico de seguimiento',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 5),

                // Graphic
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey.shade700, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ActivityProgressChart(activity: activity),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Widget that shows the details of the activity
Widget _buildDetailsTab(BuildContext context, Activity activity) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ROW 1: General information
                  const Text(
                    'Información general',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ActivityUtils().buildInfoRow('Título:', activity.title),
                  if (activity.description!.isNotEmpty)
                    ActivityUtils().buildInfoRow('Descripción:', activity.description!),
                  ActivityUtils().buildCategoryRow('Categoría:', activity.category),

                  // ROW 2: Milestone
                  const SizedBox(height: 25),
                  const Text(
                    'Hito',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ActivityUtils().buildInfoRow(
                        'Tipo:',
                        ActivityUtils().getDetailedMilestoneLabel(activity.milestone),
                      ),
                      if (activity.milestone == MilestoneType.quantity) ...[
                        ActivityUtils().buildInfoRow('Cantidad:', activity.quantity.toString()),
                        ActivityUtils().buildInfoRow('Unidad de medida:', activity.measurementUnit.toString()),
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

                  // ROW 3: Frequency
                  const SizedBox(height: 25),
                  const Text(
                    'Frecuencia',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

                  // ROW 4: Reminder
                  const SizedBox(height: 25),
                  const Text(
                    'Recordatorio',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ActivityUtils().buildInfoRow('Notificación:', activity.reminder ? 'Activada' : 'Desactivada'),

                      if (activity.reminder) ActivityUtils().buildInfoRow('Hora:', activity.reminderTime!),
                    ],
                  ),
                  const SizedBox(height: 25),

                  const Spacer(),

                  // Delete activity button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),

                      child: const Text(
                        'Eliminar actividad',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              '¿Estás seguro de que deseas eliminar la actividad "${activity.title}"?',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),

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
                                  'Toda la información y el progreso de la actividad serán eliminados de forma permanente y no se podrán recuperar',
                                  textAlign: TextAlign.justify,
                                ),
                                SizedBox(height: 12),
                              ],
                            ),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancelar'),
                              ),

                              TextButton(
                                onPressed: () {
                                  ActivityService().deleteActivityById(activity.id);
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                  StdFluttertoast.show(
                                    "¡Actividad eliminada con éxito!",
                                    Toast.LENGTH_LONG,
                                    ToastGravity.BOTTOM,
                                  );
                                },
                                child: const Text('Confirmar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
