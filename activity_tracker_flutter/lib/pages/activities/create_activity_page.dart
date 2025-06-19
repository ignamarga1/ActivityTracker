import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

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
  String? selectedCategory;
  final List<Map<String, dynamic>> categories = [
    {'label': 'Alimentación', 'icon': Icons.restaurant_rounded},
    {'label': 'Deporte', 'icon': Icons.fitness_center_sharp},
    {'label': 'Lectura', 'icon': Icons.menu_book_rounded},
    {'label': 'Salud', 'icon': Icons.local_hospital_rounded},
    {'label': 'Meditación', 'icon': Icons.self_improvement_rounded},
    {'label': 'Dejar mal hábito', 'icon': Icons.not_interested_rounded},
    {'label': 'Hogar', 'icon': Icons.home_rounded},
    {'label': 'Ocio', 'icon': Icons.movie_creation_rounded},
    {'label': 'Trabajo', 'icon': Icons.work},
    {'label': 'Estudio', 'icon': Icons.school_rounded},
    {'label': 'Social', 'icon': Icons.groups_rounded},
    {'label': 'Otro', 'icon': Icons.more_horiz_rounded},
  ];

  // Selected milestone
  MilestoneType? selectedMilestone = MilestoneType.yesNo;
  final quantityController = TextEditingController();
  final measurementeUnitController = TextEditingController();
  int selectedHours = 0;
  int selectedMinutes = 0;
  int selectedSeconds = 0;

  //final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear actividad')),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stepper(
          physics: BouncingScrollPhysics(),
          steps: getFormSteps(),
          currentStep: currentStep,
          onStepContinue: () {
            final isLastStep = currentStep == getFormSteps().length - 1;

            if (!isLastStep) {
              setState(() {
                currentStep += 1;
              });
            }
          },
          onStepCancel: () {
            currentStep == 0
                ? null
                : setState(() {
                    currentStep -= 1;
                  });
          },
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
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Título",
              ),
            ),
            const SizedBox(height: 15),

            // Description
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Descripción (opcional)",
              ),
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
            Text.rich(
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
              TextSpan(
                text: 'Selecciona la categoría más adecuada para la actividad',
              ),
            ),
            const SizedBox(height: 10),
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
                final isSelected = selectedCategory == category['label'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category['label'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade600,
                        width: 2,
                      ),
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.5)
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
                              ? Theme.of(context).colorScheme.inversePrimary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            category['label'],
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.inversePrimary
                                  : Colors.grey[300],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
            const Text.rich(
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
              TextSpan(
                text:
                    'Selecciona el tipo de hito con el que quieres evaluar el progreso de la actividad',
              ),
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
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // Measurement unit
              TextFormField(
                controller: measurementeUnitController,
                decoration: const InputDecoration(
                  labelText: 'Unidad de medida',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            // Additional fields for Timed milestone
            if (selectedMilestone == MilestoneType.timed) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hours
                  _buildTimePicker(
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
                  _buildTimePicker(
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
                  _buildTimePicker(
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
        content: Column(children: [
          ],
        ),
      ),

      // Step 5: Notification
      Step(
        isActive: currentStep >= 4,
        title: const Text('Notificación'),
        content: Column(children: [
          ],
        ),
      ),
    ];
  }

  // Custom numberpicker function for time selection
  Widget _buildTimePicker({
    required BuildContext context,
    required String label,
    required int value,
    required int max,
    required void Function(int) onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        NumberPicker(
          value: value,
          minValue: 0,
          maxValue: max,
          itemWidth: 80,
          itemHeight: 40,
          axis: Axis.vertical,
          infiniteLoop: true,
          onChanged: onChanged,
          selectedTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textStyle: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
