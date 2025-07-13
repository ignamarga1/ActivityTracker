import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:flutter/material.dart';

class SelectTemplateActivityPage extends StatefulWidget {
  const SelectTemplateActivityPage({super.key});

  @override
  State<SelectTemplateActivityPage> createState() =>
      _SelectTemplateActivityPageState();
}

class _SelectTemplateActivityPageState
    extends State<SelectTemplateActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantillas de actividades'),
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,

      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Information text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "Selecciona una de las siguientes plantillas para ayudarte a crear una nueva actividad",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // List of activities
            Expanded(
              child: StreamBuilder<List<Activity>>(
                stream: ActivityService().getTemplateActivitiesStream(),
                builder: (context, snapshot) {
                  // Waiting for the template activities list with circular progress indicator
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // No template activities
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No hay actividades aún"));
                  }

                  final templateActivities = snapshot.data!;

                  // No activities for the selected date
                  if (templateActivities.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay ninguna plantilla creada. Vuelve más tarde",
                      ),
                    );
                  }

                  // List view for every activity
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: templateActivities.length,
                    itemBuilder: (context, index) {
                      final activity = templateActivities[index];

                      // Card containing the information of the activity
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Colors.grey.shade700,
                            width: 2,
                          ),
                        ),

                        child: InkWell(
                          // Open Activity details
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/createTemplateActivity',
                              arguments: activity,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title
                                Text(
                                  activity.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                if (activity.description!.isNotEmpty)
                                  _buildInfoRow(
                                    'Descripción:',
                                    activity.description!,
                                  ),
                                _buildCategoryRow(
                                  'Categoría:',
                                  activity.category,
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                      'Tipo de hito:',
                                      getMilestoneLabel(activity.milestone),
                                    ),
                                    if (activity.milestone ==
                                        MilestoneType.quantity) ...[
                                      _buildInfoRow(
                                        'Cantidad:',
                                        activity.quantity.toString(),
                                      ),
                                      _buildInfoRow(
                                        'Unidad de medida:',
                                        activity.measurementUnit.toString(),
                                      ),
                                    ],
                                    if (activity.milestone ==
                                        MilestoneType.timed)
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

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                      'Se repite:',
                                      getFrequencyLabel(activity.frequency),
                                    ),
                                    if (activity.frequency ==
                                            FrequencyType.specificDayWeek &&
                                        activity
                                            .frequencyDaysOfWeek!
                                            .isNotEmpty)
                                      _buildInfoRow(
                                        'Días de la semana:',
                                        formatWeekDays(
                                          activity.frequencyDaysOfWeek!,
                                        ),
                                      ),
                                    if (activity.frequency ==
                                            FrequencyType.specificDayMonth &&
                                        activity
                                            .frequencyDaysOfMonth!
                                            .isNotEmpty)
                                      _buildInfoRow(
                                        'Días del mes:',
                                        formatMonthDays(
                                          activity.frequencyDaysOfMonth!,
                                        ),
                                      ),
                                  ],
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                      'Notificación:',
                                      activity.reminder
                                          ? 'Activada'
                                          : 'Desactivada',
                                    ),

                                    if (activity.reminder)
                                      _buildInfoRow(
                                        'Hora:',
                                        activity.reminderTime!,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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
