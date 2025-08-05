import 'dart:async';
import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/models/activity_progress.dart';
import 'package:activity_tracker_flutter/services/activity_progress_service.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProgressDialog extends StatefulWidget {
  final Activity activity;
  final ActivityProgress? progress;

  const ProgressDialog({super.key, required this.activity, required this.progress});

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  late int quantity;
  late int hours;
  late int minutes;
  late int seconds;

  late int goalHours;
  late int goalMinutes;
  late int goalSeconds;

  bool isTimerRunning = false;
  Timer? countdownTimer;

  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;

    quantity = widget.progress?.progressQuantity ?? 0;

    hours = widget.progress?.remainingHours ?? 0;
    minutes = widget.progress?.remainingMinutes ?? 0;
    seconds = widget.progress?.remainingSeconds ?? 0;

    goalHours = activity.durationHours ?? 0;
    goalMinutes = activity.durationMinutes ?? 0;
    goalSeconds = activity.durationSeconds ?? 0;

    isCompleted = widget.progress!.completed;
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
          setState(() {
            isTimerRunning = false;
            isCompleted = true;
          });
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

  // Function to automatically complete the timed activity
  void markTimedActivityAsCompleted() {
    setState(() {
      hours = 0;
      minutes = 0;
      seconds = 0;
      isCompleted = true;
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
        'Progreso de la actividad \n"${activity.title}"',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Behaviour for Quantity activity
          if (activity.milestone == MilestoneType.quantity) ...[
            Column(
              children: [
                Text('Cantidad actual: $quantity / ${activity.quantity}', style: TextStyle(fontSize: 15)),
                const SizedBox(height: 5),

                Text('(${activity.measurementUnit})', style: TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 10),

            // Increment and decrement quantity buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: quantity > 0
                      ? () => setState(() {
                          quantity--;
                          isCompleted = false;
                        })
                      : null,
                ),

                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: quantity < (activity.quantity ?? 0)
                      ? () => setState(() {
                          quantity++;
                          if (quantity >= (activity.quantity ?? 0)) {
                            isCompleted = true;
                          }
                        })
                      : null,
                ),
              ],
            ),

            // Complete quantity button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                setState(() {
                  quantity = activity.quantity ?? 0;
                  isCompleted = true;
                });
              },
              icon: const Icon(Icons.done),
              label: const Text('Completar'),
            ),

            // Behaviour for Timed activity
          ] else if (activity.milestone == MilestoneType.timed) ...[
            Text('Tiempo restante: ${formatTime(hours, minutes, seconds)}', style: TextStyle(fontSize: 15)),

            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start / Stop button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,

                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: toggleTimer,
                  icon: Icon(isTimerRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(isTimerRunning ? 'Pausar' : 'Iniciar'),
                ),
                const SizedBox(width: 10),

                // Complete timer button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: markTimedActivityAsCompleted,
                  icon: const Icon(Icons.check),
                  label: const Text('Completar'),
                ),
              ],
            ),
            const SizedBox(height: 25),

            Text('Objetivo: ${formatTime(goalHours, goalMinutes, goalSeconds)}', style: TextStyle(fontSize: 15)),

            // Behaviour for YesNo activity
          ] else ...[
            Text(
              '¿Estás seguro de que quieres marcar esta actividad como completada?',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            Text(
              'Estado: ${isCompleted ? 'Completada' : 'Sin completar'}',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Complete button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                setState(() {
                  isCompleted = true;
                });
              },
              icon: const Icon(Icons.done),
              label: const Text('Completar'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            ActivityProgressService().updateActivityProgress(
              activityId: activity.id,
              date: DateTime.now(),
              progressQuantity: quantity,
              remainingHours: hours,
              remainingMinutes: minutes,
              remainingSeconds: seconds,
              completed: isCompleted,
            );

            Navigator.pop(context);

            if (isCompleted) {
              StdFluttertoast.show(
                '¡Enhorabuena! Has completado la actividad 🎉',
                Toast.LENGTH_SHORT,
                ToastGravity.BOTTOM,
              );
              ActivityService().updateStreak(activity);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
