import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateActivityPage extends StatefulWidget {
  const CreateActivityPage({super.key});

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  int currentStep = 0;

  // Basic information controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // Selected category
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

  // Selected milestone
  MilestoneType? selectedMilestone = MilestoneType.yesNo;
  final quantityController = TextEditingController();
  final measurementeUnitController = TextEditingController();
  int selectedHours = 0;
  int selectedMinutes = 0;
  int selectedSeconds = 0;

  // Selected frequency
  FrequencyType? selectedFrequency = FrequencyType.everyday;
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
    titleController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    measurementeUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear actividad'), scrolledUnderElevation: 0),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Form(
          key: _formKey,
          child: Stepper(
            physics: BouncingScrollPhysics(),
            steps: getFormSteps(),
            currentStep: currentStep,
            onStepContinue: () async {
              final isLastStep = currentStep == getFormSteps().length - 1;
              bool isValid = true;

              switch (currentStep) {
                case 0:
                  isValid = _formKey.currentState?.validate() ?? false;
                  break;

                case 1:
                  isValid = selectedCategory != null;
                  break;

                case 2:
                  isValid =
                      selectedMilestone != null &&
                      (selectedMilestone == MilestoneType.yesNo ||
                          (selectedMilestone == MilestoneType.quantity && _formKey.currentState?.validate() == true) ||
                          (selectedMilestone == MilestoneType.timed &&
                              (selectedHours + selectedMinutes + selectedSeconds > 0)));
                  break;

                case 3:
                  isValid =
                      selectedFrequency != null &&
                      (selectedFrequency == FrequencyType.everyday ||
                          (selectedFrequency == FrequencyType.specificDayWeek && selectedDaysOfWeek.isNotEmpty) ||
                          (selectedFrequency == FrequencyType.specificDayMonth && selectedDaysOfMonth.isNotEmpty));
                  break;

                default:
                  isValid = true;
              }

              if (isValid) {
                if (_formKey.currentState?.validate() ?? false) {
                  if (!isLastStep) {
                    setState(() {
                      currentStep += 1;
                    });
                  } else {
                    await ActivityService().createActivity(
                      userId: FirebaseAuth.instance.currentUser!.uid,

                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      type: ActivityType.custom,
                      category: selectedCategory!,

                      milestone: selectedMilestone!,
                      quantity: selectedMilestone == MilestoneType.quantity
                          ? int.tryParse(quantityController.text) ?? 0
                          : null,
                      measurementUnit: selectedMilestone == MilestoneType.quantity
                          ? measurementeUnitController.text.trim()
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
                    StdFluttertoast.show('¡Actividad creada con éxito!', Toast.LENGTH_LONG, ToastGravity.BOTTOM);

                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  }
                }
              } else {
                StdFluttertoast.show(
                  'Hay opciones o campos obligatorios sin completar',
                  Toast.LENGTH_LONG,
                  ToastGravity.BOTTOM,
                );
              }
            },
            onStepCancel: () {
              currentStep == 0
                  ? null
                  : setState(() {
                      currentStep -= 1;
                    });
            },

            controlsBuilder: (context, details) {
              final isLastStep = currentStep == getFormSteps().length - 1;

              return Row(
                children: [
                  TextButton(onPressed: details.onStepContinue, child: Text(isLastStep ? 'Confirmar' : 'Continuar')),
                  const SizedBox(width: 8),

                  if (currentStep > 0) TextButton(onPressed: details.onStepCancel, child: const Text('Atrás')),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Step> getFormSteps() {
    return <Step>[
      // Step 1: Basic information
      Step(
        isActive: currentStep >= 0,
        title: const Text('Información'),
        content: Column(
          children: [
            const SizedBox(height: 5),
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
          ],
        ),
      ),

      // Step 2: Category
      Step(
        isActive: currentStep >= 1,
        title: const Text('Categoría'),

        // Category Grid
        content: Column(
          children: [
            // Descriptive text
            Text.rich(
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              TextSpan(text: 'Selecciona la categoría más adecuada para la actividad'),
            ),
            const SizedBox(height: 15),

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
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
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
      ),

      // Step 3: Milestone type
      Step(
        isActive: currentStep >= 2,
        title: const Text('Hito'),
        content: Column(
          children: [
            // Descriptive text
            Text.rich(
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              TextSpan(text: 'Selecciona el tipo de hito con el que quieres evaluar el progreso de la actividad'),
            ),

            const SizedBox(height: 15),

            // Options
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: MilestoneType.values.map((type) {
                final label = {
                  MilestoneType.yesNo: "Sí/No",
                  MilestoneType.quantity: "Cantidad",
                  MilestoneType.timed: "Tiempo",
                }[type];

                final isSelected = selectedMilestone == type;

                return ChoiceChip(
                  showCheckmark: false,
                  label: Text(label!),
                  selected: isSelected,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onSelected: (_) {
                    setState(() => selectedMilestone = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Additional fields for Quantity milestone
            if (selectedMilestone == MilestoneType.quantity) ...[
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
                controller: measurementeUnitController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El campo es obligatorio';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Unidad de medida', border: OutlineInputBorder()),
              ),
            ],

            // Additional fields for Timed milestone
            if (selectedMilestone == MilestoneType.timed) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hours
                  ActivityUtils().buildTimePicker(
                    context: context,
                    label: "Horas",
                    value: selectedHours,
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
                    value: selectedMinutes,
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
                    value: selectedSeconds,
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
      ),

      // Step 4: Frequency type
      Step(
        isActive: currentStep >= 3,
        title: const Text('Frecuencia'),
        content: Column(
          children: [
            // Descriptive text
            Text.rich(
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              TextSpan(text: 'Selecciona la frecuencia con la que deseas realizar la actividad'),
            ),
            const SizedBox(height: 15),

            // Options
            Wrap(
              spacing: 2,
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: FrequencyType.values.map((type) {
                final label = {
                  FrequencyType.everyday: "Diaria",
                  FrequencyType.specificDayWeek: "Día/s concreto/s de la semana",
                  FrequencyType.specificDayMonth: "Día/s concreto/s del mes",
                }[type];

                final isSelected = selectedFrequency == type;

                return ChoiceChip(
                  showCheckmark: false,
                  label: Text(label!),
                  selected: isSelected,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onSelected: (_) {
                    setState(() {
                      selectedFrequency = type;
                      if (type != FrequencyType.specificDayWeek) {
                        selectedDaysOfWeek.clear();
                      }
                      if (type != FrequencyType.specificDayMonth) {
                        selectedDaysOfMonth.clear();
                      }
                    });
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
                      selectedColor: Theme.of(context).colorScheme.primary,
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
                          label: Text('$day', style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                          selected: isSelected,
                          selectedColor: Theme.of(context).colorScheme.primary,
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
      ),

      // Step 5: Notification
      Step(
        isActive: currentStep >= 4,
        title: const Text('Notificación'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descriptive text
            Text.rich(
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              TextSpan(
                text:
                    'Selecciona si deseas recibir un recordatorio para no olvidarte de realizar la actividad y elige la hora a la que quieres que se te notifique',
              ),
            ),
            const SizedBox(height: 15),

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
                      final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
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
      ),
    ];
  }
}
