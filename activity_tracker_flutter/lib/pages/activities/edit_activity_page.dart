import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditActivityPage extends StatefulWidget {
  const EditActivityPage({super.key});

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  Activity? activity;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // Selected category
  ActivityCategory? selectedCategory;
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

  // Reminder
  bool notificationToggled = false;
  TimeOfDay? timeOfDayForReminder;

  // Form validator
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (activity != null) return;

    activity = ModalRoute.of(context)!.settings.arguments as Activity;

    titleController.text = activity!.title;
    descriptionController.text = activity!.description!;
    selectedCategory = activity!.category;
    notificationToggled = activity!.reminder;
    timeOfDayForReminder = parseTimeOfDay(activity!.reminderTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edición de actividad'),
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,

      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // New title textfield
                      TextFormField(
                        controller: titleController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo es obligatorio';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Nuevo título",
                        ),
                      ),
                      const SizedBox(height: 15),

                      // New description textfield
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Nueva descripción (opcional)",
                        ),
                      ),

                      const SizedBox(height: 30),

                      Column(
                        children: [
                          // Grid with categories
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: categories.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 2.5,
                                ),
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected =
                                  selectedCategory == category['category'];

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategory = category['category'];
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Colors.grey.shade600,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.surface,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        category['icon'],
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onPrimary
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          category['label'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time and toggle for Timepicker
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notificationToggled &&
                                          timeOfDayForReminder != null
                                      ? 'Recordatorio: ${_formatTime24h(timeOfDayForReminder!)}'
                                      : 'Recordatorio:',
                                ),
                              ),
                              Switch(
                                value: notificationToggled,
                                onChanged: (value) async {
                                  if (value) {
                                    final pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (pickedTime != null) {
                                      setState(() {
                                        notificationToggled = true;
                                        timeOfDayForReminder = pickedTime;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      notificationToggled = false;
                                      timeOfDayForReminder = null;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Save changes button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.all(15),
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

                            // Checks if any attribute was changed
                            final String newTitle = titleController.text.trim();
                            final String newDescription = descriptionController
                                .text
                                .trim();
                            final ActivityCategory? newCategory =
                                selectedCategory;
                            final bool isTitleChanged =
                                newTitle.isNotEmpty &&
                                (newTitle != activity!.title);
                            final bool isDescriptionChanged =
                                newDescription != activity!.description;
                            final bool isCategoryChanged =
                                newCategory != activity!.category;
                            final bool isReminderChanged =
                                notificationToggled != activity!.reminder;
                            final bool isReminderTimeChanged =
                                notificationToggled &&
                                timeOfDayForReminder != null &&
                                _formatTime24h(timeOfDayForReminder!) !=
                                    activity!.reminderTime;

                            // Checks if there are any changes in case the user presses the button (for not showing the Fluttertoast)
                            if (!isTitleChanged &&
                                !isDescriptionChanged &&
                                !isCategoryChanged &&
                                !isReminderChanged &&
                                !isReminderTimeChanged) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                return;
                              }
                            }

                            if (_formKey.currentState!.validate()) {
                              await ActivityService().updateActivity(
                                id: activity!.id,
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                category: selectedCategory,
                                reminder: notificationToggled,
                                reminderTime:
                                    (notificationToggled &&
                                        timeOfDayForReminder != null)
                                    ? _formatTime24h(timeOfDayForReminder!)
                                    : null,
                              );

                              // Pops the edit page
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              // FlutterToast message
                              StdFluttertoast.show(
                                '¡Actividad editada con éxito!',
                                Toast.LENGTH_LONG,
                                ToastGravity.BOTTOM,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Converts time format for TimePicker
String _formatTime24h(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

// Converts String time to TimeOfDay
TimeOfDay? parseTimeOfDay(String? timeString) {
  if (timeString == null) return null;

  final parts = timeString.split(':');
  if (parts.length != 2) return null;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);

  if (hour == null || minute == null) return null;

  return TimeOfDay(hour: hour, minute: minute);
}
