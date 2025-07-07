import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:activity_tracker_flutter/components/progress_dialog.dart';
import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/models/activity_progress.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/activity_progress_service.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      // Appbar with current selected date
      appBar: AppBar(
        title: DateUtils.isSameDay(_selectedDate, DateTime.now())
            ? const Text('Hoy')
            : Text(
                DateFormat.yMMMMd('es_ES').format(_selectedDate),
                style: TextStyle(fontSize: 20),
              ),
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),

      body: Column(
        children: [
          // EasyDatetime picker
          EasyTheme(
            data: EasyTheme.of(context).copyWithState(
              selectedCurrentDayTheme: DayThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),

              unselectedCurrentDayTheme: DayThemeData(
                border: BorderSide(
                  width: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),

              selectedDayTheme: DayThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),

              unselectedDayTheme: DayThemeData(
                border: BorderSide(width: 2, color: Colors.grey.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),

            child: EasyDateTimeLinePicker(
              locale: Locale('es', 'ES'),
              focusedDate: _selectedDate,
              firstDate: user.createdAt.toDate(),
              lastDate: DateTime(2099, 12, 31),
              onDateChange: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              headerOptions: HeaderOptions(
                headerBuilder: (context, date, onTap) {
                  return Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(
                      top: 5,
                      bottom: 10,
                      right: 25,
                    ),
                    child: GestureDetector(
                      onTap: onTap,
                      child: const Icon(Icons.calendar_month, size: 25),
                    ),
                  );
                },
              ),
            ),
          ),

          // My activities text and filter button
          Padding(
            padding: const EdgeInsets.only(top: 25, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis actividades',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  tooltip: 'Filtrar actividades',
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // List of activities
          Expanded(
            child: StreamBuilder<List<Activity>>(
              stream: ActivityService().getUserActivitiesStream(user.uid),
              builder: (context, snapshot) {
                // Waiting for the activities list with circular progress indicator
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // User hasn't created / received from a challenge any activities yet
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay actividades aún."));
                }

                // Filters user's activity list by the selected date
                final allActivities = snapshot.data!;
                final visibleActivities = allActivities
                    .where(
                      (activity) =>
                          isActivityForSelectedDate(activity, _selectedDate),
                    )
                    .toList();

                // No activities for the selected date
                if (visibleActivities.isEmpty) {
                  return const Center(
                    child: Text("No hay actividades para este día."),
                  );
                }

                // List view for every activity
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: visibleActivities.length,
                  itemBuilder: (context, index) {
                    final activity = visibleActivities[index];

                    // Activity progress
                    return StreamBuilder<ActivityProgress>(
                      stream: ActivityProgressService().getOrCreateProgress(
                        activityId: activity.id,
                        date: _selectedDate,
                        createdAt: activity.createdAt,
                        initialQuantity: activity.milestone == MilestoneType.quantity ? 0 : null,
                        remainingHours: activity.durationHours,
                        remainingMinutes: activity.durationMinutes,
                        remainingSeconds: activity.durationSeconds,
                      ),
                      builder: (context, progressSnapshot) {
                        // Waiting for every activity progress
                        if (!progressSnapshot.hasData) {
                          return const Center(
                            // child: CircularProgressIndicator(),
                          );
                        }
                        final progress = progressSnapshot.data!;

                        // Category icons
                        final categoryIcon = {
                          ActivityCategory.nutrition: Icons.restaurant_rounded,
                          ActivityCategory.sport: Icons.fitness_center_sharp,
                          ActivityCategory.reading: Icons.menu_book_rounded,
                          ActivityCategory.health: Icons.local_hospital_rounded,
                          ActivityCategory.meditation:
                              Icons.self_improvement_rounded,
                          ActivityCategory.quitBadHabit:
                              Icons.not_interested_rounded,
                          ActivityCategory.home: Icons.home_rounded,
                          ActivityCategory.entertainment:
                              Icons.movie_creation_rounded,
                          ActivityCategory.work: Icons.work,
                          ActivityCategory.study: Icons.school_rounded,
                          ActivityCategory.social: Icons.groups_rounded,
                          ActivityCategory.other: Icons.more_horiz_rounded,
                        }[activity.category];

                        // Trailing based on the activity milestone
                        Widget trailing;
                        switch (activity.milestone) {
                          case MilestoneType.yesNo:
                            trailing = SizedBox(
                              height: 50,
                              width: 45,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    progress.completed
                                        ? Icons
                                              .check_circle_outline_rounded 
                                        : Icons
                                              .radio_button_unchecked, 
                                    size: 20,
                                  ),
                                ],
                              ),
                            );
                            break;

                          case MilestoneType.quantity:
                            trailing = SizedBox(
                              height: 50,
                              width: 45,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.donut_large_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${progress.progressQuantity} / ${activity.quantity}',
                                  ),
                                ],
                              ),
                            );
                            break;

                          case MilestoneType.timed:
                            final remainingDuration = Duration(
                              hours:
                                  progress.remainingHours ??
                                  activity.durationHours!,
                              minutes:
                                  progress.remainingMinutes ??
                                  activity.durationMinutes!,
                              seconds:
                                  progress.remainingSeconds ??
                                  activity.durationSeconds!,
                            );

                            String formatDuration(Duration d) {
                              final h = d.inHours.toString().padLeft(2, '0');
                              final m = (d.inMinutes % 60).toString().padLeft(
                                2,
                                '0',
                              );
                              final s = (d.inSeconds % 60).toString().padLeft(
                                2,
                                '0',
                              );
                              return '$h:$m:$s';
                            }

                            trailing = SizedBox(
                              height: 50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.timer_outlined, size: 20),
                                  const SizedBox(height: 2),
                                  Text(formatDuration(remainingDuration)),
                                ],
                              ),
                            );
                            break;
                        }

                        // Card containing the information of the activity
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),

                          // Color changes based in the progress
                          color: () {
                            final today = DateTime.now();
                            final progressDate = DateFormat(
                              'dd-MM-yyyy',
                            ).parse(progress.date);

                            if (progress.completed) {
                              return Colors.green.shade800;
                            } else if (progressDate.isBefore(
                              DateTime(today.year, today.month, today.day),
                            )) {
                              return Colors.red.shade500;
                            } else {
                              return Theme.of(context).colorScheme.surface;
                            }
                          }(),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              // Border color changes based in the progress
                              color: () {
                                final today = DateTime.now();
                                final progressDate = DateFormat(
                                  'dd-MM-yyyy',
                                ).parse(progress.date);

                                if (progress.completed) {
                                  return Colors.green.shade800;
                                } else if (progressDate.isBefore(
                                  DateTime(today.year, today.month, today.day),
                                )) {
                                  return Colors.red.shade500;
                                } else {
                                  return Colors.grey.shade700;
                                }
                              }(),
                              width: 2,
                            ),
                          ),

                          child: ListTile(
                            leading: Icon(categoryIcon),
                            title: Text(
                              activity.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle:
                                activity.description != null &&
                                    activity.description!.isNotEmpty
                                ? Text(activity.description!)
                                : null,
                            trailing: trailing,

                            // Open Activity details
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/activityDetails',
                                arguments: activity,
                              );
                            },

                            // Open activity progress menu
                            onLongPress: () {
                              // Can't edit the progress for an activity from other day
                              if (!_isToday(_selectedDate)) {
                                StdFluttertoast.show(
                                  "Solo puedes cambiar el progreso de las actividades de hoy",
                                  Toast.LENGTH_LONG,
                                  ToastGravity.BOTTOM,
                                );
                                // Can't edit the progress for a completed activity
                              } else if (progress.completed) {
                                StdFluttertoast.show(
                                  "La actividad ya se ha completado y no se puede modificar su progreso",
                                  Toast.LENGTH_LONG,
                                  ToastGravity.BOTTOM,
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => ProgressDialog(
                                    activity: activity,
                                    progress: progress,
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // New activity button
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Bottom sheet with new activity options
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Options: custom and with template
                    ListTile(
                      leading: const Icon(Icons.edit_document),
                      title: const Text('Actividad personalizada'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/createActivity');
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.note_add),
                      title: const Text('Actividad con plantilla'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/createActivity');
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Converts Datetime.weekday to Firestore index (1-7 -> 0-6)
  int getDayOfWeekIndex(DateTime date) {
    return (date.weekday + 6) % 7;
  }

  // Checks if an activity is scheduled for a selected date (taking into account the activity's creation date)
  bool isActivityForSelectedDate(Activity activity, DateTime selectedDate) {
    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final created = DateTime(
      activity.createdAt.toDate().year,
      activity.createdAt.toDate().month,
      activity.createdAt.toDate().day,
    );

    // Ensures new activities don't show up in days previous to its creation
    if (selected.isBefore(created)) return false;

    // Filters the activities by their frequency
    switch (activity.frequency) {
      case FrequencyType.everyday:
        return true;

      case FrequencyType.specificDayWeek:
        final dayIndex = getDayOfWeekIndex(selectedDate);
        return activity.frequencyDaysOfWeek?.contains(dayIndex) ?? false;

      case FrequencyType.specificDayMonth:
        return activity.frequencyDaysOfMonth?.contains(selectedDate.day) ??
            false;
    }
  }

  // Checks if the parameter date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
