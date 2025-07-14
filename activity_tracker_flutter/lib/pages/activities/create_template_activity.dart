import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateTemplateActivityPage extends StatefulWidget {
  const CreateTemplateActivityPage({super.key});

  @override
  State<CreateTemplateActivityPage> createState() => _CreateTemplateActivityPageState();
}

class _CreateTemplateActivityPageState extends State<CreateTemplateActivityPage> {
  Activity? activity;

  // Information
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // Category
  ActivityCategory? selectedCategory;
  final List<Map<String, dynamic>> categories = [
    {'category': ActivityCategory.nutrition, 'label': 'Alimentación', 'icon': Icons.restaurant_rounded},
    {'category': ActivityCategory.sport, 'label': 'Deporte', 'icon': Icons.fitness_center_sharp},
    {'category': ActivityCategory.reading, 'label': 'Lectura', 'icon': Icons.menu_book_rounded},
    {'category': ActivityCategory.health, 'label': 'Salud', 'icon': Icons.local_hospital_rounded},
    {'category': ActivityCategory.meditation, 'label': 'Meditación', 'icon': Icons.self_improvement_rounded},
    {'category': ActivityCategory.quitBadHabit, 'label': 'Dejar mal hábito', 'icon': Icons.not_interested_rounded},
    {'category': ActivityCategory.home, 'label': 'Hogar', 'icon': Icons.home_rounded},
    {'category': ActivityCategory.entertainment, 'label': 'Ocio', 'icon': Icons.movie_creation_rounded},
    {'category': ActivityCategory.work, 'label': 'Trabajo', 'icon': Icons.work},
    {'category': ActivityCategory.study, 'label': 'Estudio', 'icon': Icons.school_rounded},
    {'category': ActivityCategory.social, 'label': 'Social', 'icon': Icons.groups_rounded},
    {'category': ActivityCategory.other, 'label': 'Otro', 'icon': Icons.more_horiz_rounded},
  ];

  // Milestone
  MilestoneType? selectedMilestone;
  final quantityController = TextEditingController();
  final measurementUnitController = TextEditingController();
  int selectedHours = 0;
  int selectedMinutes = 0;
  int selectedSeconds = 0;

  // Frequency
  FrequencyType? selectedFrequency;
  final daysOfWeek = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  List<int> selectedDaysOfWeek = [];
  List<int> selectedDaysOfMonth = [];

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
    quantityController.dispose();
    measurementUnitController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (activity != null) return;

    activity = ModalRoute.of(context)!.settings.arguments as Activity;

    titleController.text = activity!.title;
    descriptionController.text = activity!.description!;

    selectedCategory = activity!.category;

    selectedMilestone = activity!.milestone;
    if (activity!.milestone == MilestoneType.quantity) {
      quantityController.text = activity!.quantity!.toString();
      measurementUnitController.text = activity!.measurementUnit!;
    }

    if (activity!.milestone == MilestoneType.timed) {
      selectedHours = activity!.durationHours!;
      selectedMinutes = activity!.durationMinutes!;
      selectedSeconds = activity!.durationSeconds!;
    }

    selectedFrequency = activity!.frequency;
    if (activity!.frequency == FrequencyType.specificDayWeek) {
      selectedDaysOfWeek = activity!.frequencyDaysOfWeek!;
    }

    if (activity!.frequency == FrequencyType.specificDayMonth) {
      selectedDaysOfMonth = activity!.frequencyDaysOfMonth!;
    }

    notificationToggled = activity!.reminder;
    timeOfDayForReminder = ActivityUtils().parseTimeOfDay(activity!.reminderTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear actividad por plantilla'), scrolledUnderElevation: 0),
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
                      // INFORMATION
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Información', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      TextFormField(
                        controller: titleController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo es obligatorio';
                          }
                          return null;
                        },
                        decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Título"),
                      ),
                      const SizedBox(height: 15),

                      // Description
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Descripción (opcional)"),
                      ),
                      const SizedBox(height: 30),

                      // CATEGORY
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Categoría', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(height: 20),

                      Column(
                        children: [
                          // Grid with categories
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: categories.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 8,
                              childAspectRatio: 2.5,
                            ),
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = selectedCategory == category['category'];

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
                                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade600,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.surface,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        category['icon'],
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.onPrimary
                                            : Theme.of(context).colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          category['label'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected
                                                ? Theme.of(context).colorScheme.onPrimary
                                                : Theme.of(context).colorScheme.onSurface,
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

                      // MILESTONE
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Hito (${ActivityUtils().getMilestoneLabel(activity!.milestone)})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Column(
                        children: [
                          // Additional fields for Quantity milestone
                          if (activity!.milestone == MilestoneType.quantity) ...[
                            // Quantity
                            TextFormField(
                              controller: quantityController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El campo es obligatorio';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                            ),

                            const SizedBox(height: 15),

                            // Measurement unit
                            TextFormField(
                              controller: measurementUnitController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El campo es obligatorio';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Unidad de medida',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],

                          // Additional fields for Timed milestone
                          if (activity!.milestone == MilestoneType.timed) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hours
                                ActivityUtils().buildTimePicker(
                                  context: context,
                                  label: "Horas",
                                  value: activity!.durationHours!,
                                  max: 23,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedHours = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 15),

                                // Minutes
                                ActivityUtils().buildTimePicker(
                                  context: context,
                                  label: "Minutos",
                                  value: activity!.durationMinutes!,
                                  max: 59,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedMinutes = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 15),

                                // Seconds
                                ActivityUtils().buildTimePicker(
                                  context: context,
                                  label: "Segundos",
                                  value: activity!.durationSeconds!,
                                  max: 59,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSeconds = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 30),

                      // FREQUENCY
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Frecuencia', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(height: 20),

                      Column(
                        children: [
                          // Options
                          Wrap(
                            spacing: 2,
                            direction: Axis.vertical,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: FrequencyType.values.map((type) {
                              final isSelected = selectedFrequency == type;

                              return ChoiceChip(
                                showCheckmark: false,
                                label: Text(ActivityUtils().getFrequencyLabel(type)),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() => selectedFrequency = type);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Additional fields for Days of week
                          if (selectedFrequency == FrequencyType.specificDayWeek) ...[
                            SizedBox(
                              width: 240,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: List.generate(7, (index) {
                                  final isSelected = selectedDaysOfWeek.contains(index);

                                  return FilterChip(
                                    showCheckmark: false,
                                    label: Text(daysOfWeek[index]),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      setState(() {
                                        isSelected ? selectedDaysOfWeek.remove(index) : selectedDaysOfWeek.add(index);
                                      });
                                    },
                                  );
                                }),
                              ),
                            ),
                          ],

                          // Additional fields for Days of month
                          if (selectedFrequency == FrequencyType.specificDayMonth) ...[
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final chipWidth = (constraints.maxWidth - (5 * 5)) / 7;

                                return Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  alignment: WrapAlignment.center,
                                  children: List.generate(31, (index) {
                                    final day = index + 1;
                                    final isSelected = selectedDaysOfMonth.contains(day);

                                    return SizedBox(
                                      width: chipWidth,
                                      child: FilterChip(
                                        label: Text(
                                          '$day',
                                          style: const TextStyle(fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                                        selected: isSelected,
                                        showCheckmark: false,
                                        onSelected: (_) {
                                          setState(() {
                                            if (isSelected) {
                                              selectedDaysOfMonth.remove(day);
                                            } else {
                                              selectedDaysOfMonth.add(day);
                                            }
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 30),

                      // NOTIFICATION
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Notificación', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time and toggle for Timepicker
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notificationToggled && timeOfDayForReminder != null
                                      ? 'Recordatorio: ${ActivityUtils().formatTime24h(timeOfDayForReminder!)}'
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

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),

                          child: const Text(
                            'Crear actividad',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),

                          onPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();

                            if (_formKey.currentState!.validate()) {
                              ActivityService().createActivity(
                                userId: FirebaseAuth.instance.currentUser!.uid,

                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                category: selectedCategory!,

                                milestone: selectedMilestone!,
                                quantity: selectedMilestone == MilestoneType.quantity
                                    ? int.tryParse(quantityController.text) ?? 0
                                    : null,
                                measurementUnit: selectedMilestone == MilestoneType.quantity
                                    ? measurementUnitController.text.trim()
                                    : null,
                                durationHours: selectedMilestone == MilestoneType.timed ? selectedHours : null,
                                durationMinutes: selectedMilestone == MilestoneType.timed ? selectedMinutes : null,
                                durationSeconds: selectedMilestone == MilestoneType.timed ? selectedSeconds : null,
                                frequency: selectedFrequency!,
                                frequencyDaysOfWeek: selectedDaysOfWeek,
                                frequencyDaysOfMonth: selectedDaysOfMonth,
                                reminder: notificationToggled,
                                reminderTime: (notificationToggled && timeOfDayForReminder != null)
                                    ? ActivityUtils().formatTime24h(timeOfDayForReminder!)
                                    : null,
                                createdAt: Timestamp.now(),
                              );

                              // Pops to the home page
                              if (context.mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                              }

                              // FlutterToast message
                              StdFluttertoast.show(
                                '¡Actividad creada con éxito!',
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
