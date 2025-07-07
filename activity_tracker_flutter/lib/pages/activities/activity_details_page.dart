import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ActivityDetailsPage extends StatefulWidget {
  const ActivityDetailsPage({super.key});

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage>
    with TickerProviderStateMixin {
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
          return const Scaffold(
            body: Center(child: Text('No se pudo cargar la actividad')),
          );
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
                  Navigator.pushNamed(
                    context,
                    '/editActivity',
                    arguments: activity,
                  );
                },
              ),
            ],
          ),

          // TabBar contents
          body: TabBarView(
            controller: tabBarController,
            children: [
              _buildStatisticsTab(context, activity),
              _buildDetailsTab(context, activity),
            ],
          ),
        );
      },
    );
  }
}

// Widget that shows the statistics of the activity
Widget _buildStatisticsTab(BuildContext context, Activity activity) {
  return const Center(child: Text('Estadísticas'));
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
                  _buildInfoRow('Título:', activity.title),
                  if (activity.description!.isNotEmpty)
                    _buildInfoRow('Descripción:', activity.description!),
                  _buildCategoryRow('Categoría:', activity.category),

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
                      _buildInfoRow(
                        'Tipo:',
                        getMilestoneLabel(activity.milestone),
                      ),
                      if (activity.milestone == MilestoneType.quantity) ...[
                        _buildInfoRow(
                          'Cantidad:',
                          activity.quantity.toString(),
                        ),
                        _buildInfoRow(
                          'Unidad de medida:',
                          activity.measurementUnit.toString(),
                        ),
                      ],
                      if (activity.milestone == MilestoneType.timed)
                        _buildInfoRow(
                          'Tiempo:',
                          formatTime(
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
                      _buildInfoRow(
                        'Se repite:',
                        getFrequencyLabel(activity.frequency),
                      ),
                      if (activity.frequency == FrequencyType.specificDayWeek &&
                          activity.frequencyDaysOfWeek!.isNotEmpty)
                        _buildInfoRow(
                          'Días de la semana:',
                          formatWeekDays(activity.frequencyDaysOfWeek!),
                        ),
                      if (activity.frequency ==
                              FrequencyType.specificDayMonth &&
                          activity.frequencyDaysOfMonth!.isNotEmpty)
                        _buildInfoRow(
                          'Días del mes:',
                          formatMonthDays(activity.frequencyDaysOfMonth!),
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
                      _buildInfoRow(
                        'Notificación:',
                        activity.reminder ? 'Activada' : 'Desactivada',
                      ),

                      if (activity.reminder)
                        _buildInfoRow('Hora:', activity.reminderTime!),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      child: const Text(
                        'Eliminar actividad',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              '¿Estás seguro de que deseas eliminar la actividad "${activity.title}"?',
                            ),

                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Esta acción es permanente',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Toda la información y el progreso de la actividad serán eliminados de forma permanente y no se podrán recuperar',
                                ),
                                SizedBox(height: 12),
                              ],
                            ),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  ActivityService().deleteActivityById(
                                    activity.id,
                                  );
                                  Navigator.popUntil(
                                    context,
                                    (route) => route.isFirst,
                                  );
                                  StdFluttertoast.show(
                                    "¡Actividad eliminada con éxito!",
                                    Toast.LENGTH_LONG,
                                    ToastGravity.BOTTOM,
                                  );
                                },
                                child: const Text('Confirmar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancelar'),
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

// Widget that builds a row with the information information passed by parameters
Widget _buildInfoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

// Similar to buildInfoRow but with some modifications to fit Category necessities
Widget _buildCategoryRow(String title, ActivityCategory category) {
  final info = getCategoryInfo(category);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(width: 10),

        Row(
          children: [
            Icon(info['icon'], size: 20),
            const SizedBox(width: 10),
            Text(
              info['label'],
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    ),
  );
}

// Function that returns the category's label and icon
Map<String, dynamic> getCategoryInfo(ActivityCategory category) {
  // Activity categories
  final List<Map<String, dynamic>> categories = [
    {
      'category': ActivityCategory.nutrition,
      'label': 'Alimentación',
      'icon': Icons.restaurant_rounded,
    },
    {
      'category': ActivityCategory.sport,
      'label': 'Deporte',
      'icon': Icons.fitness_center_sharp,
    },
    {
      'category': ActivityCategory.reading,
      'label': 'Lectura',
      'icon': Icons.menu_book_rounded,
    },
    {
      'category': ActivityCategory.health,
      'label': 'Salud',
      'icon': Icons.local_hospital_rounded,
    },
    {
      'category': ActivityCategory.meditation,
      'label': 'Meditación',
      'icon': Icons.self_improvement_rounded,
    },
    {
      'category': ActivityCategory.quitBadHabit,
      'label': 'Dejar mal hábito',
      'icon': Icons.not_interested_rounded,
    },
    {
      'category': ActivityCategory.home,
      'label': 'Hogar',
      'icon': Icons.home_rounded,
    },
    {
      'category': ActivityCategory.entertainment,
      'label': 'Ocio',
      'icon': Icons.movie_creation_rounded,
    },
    {'category': ActivityCategory.work, 'label': 'Trabajo', 'icon': Icons.work},
    {
      'category': ActivityCategory.study,
      'label': 'Estudio',
      'icon': Icons.school_rounded,
    },
    {
      'category': ActivityCategory.social,
      'label': 'Social',
      'icon': Icons.groups_rounded,
    },
    {
      'category': ActivityCategory.other,
      'label': 'Otro',
      'icon': Icons.more_horiz_rounded,
    },
  ];

  return categories.firstWhere(
    (c) => c['category'] == category,
    orElse: () => {'label': 'Desconocido', 'icon': Icons.help_outline_rounded},
  );
}

// Function that returns the Frequency's label
String getFrequencyLabel(FrequencyType type) {
  return {
        FrequencyType.everyday: "Diariamente",
        FrequencyType.specificDayWeek: "Día/s concreto/s de la semana",
        FrequencyType.specificDayMonth: "Día/s concreto/s del mes",
      }[type] ??
      "Desconocida";
}

// Function that returns the Milestone's label
String getMilestoneLabel(MilestoneType type) {
  return {
        MilestoneType.yesNo: "Sí/No",
        MilestoneType.quantity: "Por cantidad",
        MilestoneType.timed: "Por tiempo",
      }[type] ??
      "Desconocida";
}

// Function that formats the list of days of the week into a String
String formatWeekDays(List<int> days) {
  const weekDays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  return days.map((d) => weekDays[d]).join(', ');
}

// Function that formats the list of days of the month into a String
String formatMonthDays(List<int> days) {
  return days.map((d) => d.toString()).join(', ');
}

// Function that formats the time for the Timed activities
String formatTime(int h, int m, int s) {
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
