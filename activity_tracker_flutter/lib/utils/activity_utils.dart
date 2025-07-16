// Custom numberpicker function for time selection
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class ActivityUtils {
  // Function that returns the Category's label
  String getCategoryLabel(ActivityCategory category) {
    return {
          ActivityCategory.nutrition: "Alimentación",
          ActivityCategory.sport: "Deporte",
          ActivityCategory.reading: "Lectura",
          ActivityCategory.health: "Salud",
          ActivityCategory.meditation: "Meditación",
          ActivityCategory.quitBadHabit: "Dejar mal hábito",
          ActivityCategory.home: "Hogar",
          ActivityCategory.entertainment: "Ocio",
          ActivityCategory.work: "Trabajo",
          ActivityCategory.study: "Estudio",
          ActivityCategory.social: "Social",
          ActivityCategory.other: "Otro",
        }[category] ??
        "Desconocida";
  }

  // Function that returns the Category's icon
  IconData getCategoryIcon(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.nutrition:
        return Icons.restaurant_rounded;
      case ActivityCategory.sport:
        return Icons.fitness_center_sharp;
      case ActivityCategory.reading:
        return Icons.menu_book_rounded;
      case ActivityCategory.health:
        return Icons.local_hospital_rounded;
      case ActivityCategory.meditation:
        return Icons.self_improvement_rounded;
      case ActivityCategory.quitBadHabit:
        return Icons.not_interested_rounded;
      case ActivityCategory.home:
        return Icons.home_rounded;
      case ActivityCategory.entertainment:
        return Icons.movie_creation_rounded;
      case ActivityCategory.work:
        return Icons.work;
      case ActivityCategory.study:
        return Icons.school_rounded;
      case ActivityCategory.social:
        return Icons.groups_rounded;
      case ActivityCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  // Function that returns the Category's label and icon
  Map<String, dynamic> getCategoryInfo(ActivityCategory category) {
    // Activity categories
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

    return categories.firstWhere(
      (c) => c['category'] == category,
      orElse: () => {'label': 'Desconocido', 'icon': Icons.help_outline_rounded},
    );
  }

  // Function that returns the Milestone's label
  String getMilestoneLabel(MilestoneType type) {
    return {MilestoneType.yesNo: "Sí/No", MilestoneType.quantity: "Cantidad", MilestoneType.timed: "Tiempo"}[type] ??
        "Desconocida";
  }

  // Function that returns the Milestone's label
  String getFrequencyLabel(FrequencyType type) {
    return {
          FrequencyType.everyday: "Diaria",
          FrequencyType.specificDayWeek: "Día/s concreto/s de la semana",
          FrequencyType.specificDayMonth: "Día/s concreto/s del mes",
        }[type] ??
        "Desconocida";
  }

  // Converts Datetime.weekday to Firestore index (1-7 -> 0-6)
  int getDayOfWeekIndex(DateTime date) {
    return (date.weekday + 6) % 7;
  }

  // Converts time format for TimePicker
  String formatTime24h(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Function that formats the list of days of the week into a String
  String formatWeekDays(List<int> days) {
    const weekDays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
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

  // Formats the activity duration
  String formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // Custom numberpicker function for time selection
  Widget buildTimePicker({
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
