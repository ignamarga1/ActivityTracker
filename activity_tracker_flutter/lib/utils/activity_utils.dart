// Custom numberpicker function for time selection
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class ActivityUtils {
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

  // Function that returns the Milestone's label
  String getMilestoneLabel(MilestoneType type) {
    return {
          MilestoneType.yesNo: "Sí/No",
          MilestoneType.quantity: "Cantidad",
          MilestoneType.timed: "Tiempo",
        }[type] ??
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

  // Converts time format for TimePicker
  String formatTime24h(TimeOfDay time) {
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
}
