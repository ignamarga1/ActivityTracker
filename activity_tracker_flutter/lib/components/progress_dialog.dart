import 'dart:async';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:activity_tracker_flutter/models/activity.dart';

class ProgressDialog extends StatefulWidget {
  final Activity activity;

  const ProgressDialog({super.key, required this.activity});

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  late int progress;
  late int hours;
  late int minutes;
  late int seconds;

  late int goalHours;
  late int goalMinutes;
  late int goalSeconds;

  bool isTimerRunning = false;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;

    progress = activity.progressQuantity ?? 0;

    hours = activity.remainingHours ?? 0;
    minutes = activity.remainingMinutes ?? 0;
    seconds = activity.remainingSeconds ?? 0;

    goalHours = activity.durationHours ?? 0;
    goalMinutes = activity.durationMinutes ?? 0;
    goalSeconds = activity.durationSeconds ?? 0;
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  // Function for timer
  void toggleTimer() {
    if (isTimerRunning) {
      countdownTimer?.cancel();
    } else {
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (hours == 0 && minutes == 0 && seconds == 0) {
          countdownTimer?.cancel();
          setState(() => isTimerRunning = false);
        } else {
          setState(() {
            if (seconds > 0) {
              seconds--;
            } else {
              if (minutes > 0) {
                minutes--;
                seconds = 59;
              } else if (hours > 0) {
                hours--;
                minutes = 59;
                seconds = 59;
              }
            }
          });
        }
      });
    }
    setState(() {
      isTimerRunning = !isTimerRunning;
    });
  }

  void markAsCompleted() {
    setState(() {
      hours = 0;
      minutes = 0;
      seconds = 0;
    });
    countdownTimer?.cancel();
    isTimerRunning = false;
  }

  String formatTime(int h, int m, int s) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

    return AlertDialog(
      // Dialog text
      title: Text(
        'Progreso de "${activity.title}"',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Behaviour for Quantity activity
          if (activity.milestone == MilestoneType.quantity) ...[
            Column(
              children: [
                Text(
                  'Cantidad actual: $progress / ${activity.quantity}',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 5),

                Text(
                  '(${activity.measurementUnit})',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (progress > 0) {
                      setState(() => progress--);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    if (progress < (activity.quantity ?? 0)) {
                      setState(() => progress++);
                    }
                  },
                ),
              ],
            ),

            // Behaviour for Timed activity
          ] else if (activity.milestone == MilestoneType.timed) ...[
            Text(
              'Tiempo restante: ${formatTime(hours, minutes, seconds)}',
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: toggleTimer,
                  icon: Icon(isTimerRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(isTimerRunning ? 'Pausar' : 'Iniciar'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: markAsCompleted,
                  label: const Text('Completar'),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              'Objetivo: ${formatTime(goalHours, goalMinutes, goalSeconds)}',
              style: TextStyle(fontSize: 15),
            ),

            // Behaviour for yesNo activity
          ] else ...[
            const Text('WIP'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            ActivityService().updateActivityProgress(
              id: activity.id,
              progressQuantity: progress,
              remainingHours: hours,
              remainingMinutes: minutes,
              remainingSeconds: seconds,
            );

            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
