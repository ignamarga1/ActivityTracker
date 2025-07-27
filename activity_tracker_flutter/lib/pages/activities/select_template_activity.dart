import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:flutter/material.dart';

class SelectTemplateActivityPage extends StatefulWidget {
  const SelectTemplateActivityPage({super.key});

  @override
  State<SelectTemplateActivityPage> createState() => _SelectTemplateActivityPageState();
}

class _SelectTemplateActivityPageState extends State<SelectTemplateActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plantillas de actividades'), scrolledUnderElevation: 0),
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Selecciona una de las siguientes plantillas para ayudarte a crear una nueva actividad",
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                    return const Center(child: Text("No hay ninguna plantilla creada. Vuelve más tarde"));
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
                          side: BorderSide(color: Colors.grey.shade700, width: 2),
                        ),

                        child: InkWell(
                          // Open Activity details
                          onTap: () {
                            Navigator.pushNamed(context, '/createTemplateActivity', arguments: activity);
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 10),

                                if (activity.description!.isNotEmpty)
                                  ActivityUtils().buildInfoRow('Descripción:', activity.description!),
                                ActivityUtils().buildCategoryRow('Categoría:', activity.category),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ActivityUtils().buildInfoRow('Tipo de hito:', ActivityUtils().getDetailedMilestoneLabel(activity.milestone)),
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

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ActivityUtils().buildInfoRow('Se repite:', ActivityUtils().getDetailedFrequencyLabel(activity.frequency)),
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
                                    ActivityUtils().buildInfoRow('Notificación:', activity.reminder ? 'Activada' : 'Desactivada'),

                                    if (activity.reminder) ActivityUtils().buildInfoRow('Hora:', activity.reminderTime!),
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