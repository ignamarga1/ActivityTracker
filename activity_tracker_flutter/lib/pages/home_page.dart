import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:activity_tracker_flutter/components/progress_dialog.dart';
import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/models/activity_progress.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/activity_progress_service.dart';
import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:activity_tracker_flutter/services/notification_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late EasyDatePickerController _dateController;

  // Filter attributes
  bool _showFilterSection = false;
  String _selectedFilterTitle = '';
  late TextEditingController _filterTitleController;
  ActivityCategory? _selectedFilterCategory;
  MilestoneType? _selectedFilterMilestone;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateController = EasyDatePickerController();
    _filterTitleController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _filterTitleController.dispose();
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
            : Text(DateFormat.yMMMMd('es_ES').format(_selectedDate), style: TextStyle(fontSize: 20)),
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,
      drawer: HomeDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width / 5,

      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            // EasyDatetime picker
            EasyTheme(
              data: EasyTheme.of(context).copyWithState(
                selectedCurrentDayTheme: DayThemeData(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),

                unselectedCurrentDayTheme: DayThemeData(
                  border: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),

                selectedDayTheme: DayThemeData(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),

                unselectedDayTheme: DayThemeData(
                  border: BorderSide(width: 2, color: Colors.grey.shade700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
              ),

              child: EasyDateTimeLinePicker(
                locale: Locale('es', 'ES'),
                controller: _dateController,
                focusedDate: _selectedDate,
                firstDate: user.createdAt.toDate(),
                lastDate: DateTime(2099, 12, 31),
                onDateChange: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                monthYearPickerOptions: MonthYearPickerOptions(cancelText: 'Cancelar', confirmText: 'Aceptar'),
                headerOptions: HeaderOptions(
                  headerBuilder: (context, date, onTap) {
                    return Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(top: 5, bottom: 10, right: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Today button
                          IconButton(
                            tooltip: 'Ir a hoy',
                            icon: const Icon(Icons.today_rounded, size: 25),
                            onPressed: () {
                              _dateController.animateToDate(DateTime.now());
                              setState(() {
                                _selectedDate = DateTime.now();
                              });
                            },
                          ),

                          // Select date button
                          IconButton(
                            tooltip: 'Seleccionar fecha',
                            icon: const Icon(Icons.calendar_month_rounded, size: 25),
                            onPressed: onTap,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // My activities text, filter and order buttons
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mis actividades', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.filter_list_rounded),
                        tooltip: 'Filtrar actividades',
                        onPressed: () {
                          setState(() {
                            _showFilterSection = !_showFilterSection;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filters section
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              alignment: AlignmentGeometry.directional(0, 5),
              curve: Curves.linearToEaseOut,
              child: _showFilterSection
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        children: [
                          // Title filter
                          TextField(
                            controller: _filterTitleController,
                            decoration: InputDecoration(
                              labelText: 'Introduce el título de una actividad',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedFilterTitle = value;
                              });
                            },
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              // ActivityCategory filter (dropdown)
                              Expanded(
                                child: DropdownMenu<ActivityCategory?>(
                                  key: ValueKey(_selectedFilterCategory),
                                  initialSelection: _selectedFilterCategory,
                                  label: const Text('Por categoría'),
                                  menuStyle: MenuStyle(
                                    // Limits de dropdown length
                                    maximumSize: WidgetStateProperty.all(const Size(double.infinity, 150)),
                                  ),
                                  dropdownMenuEntries: ActivityCategory.values.map((category) {
                                    return DropdownMenuEntry(
                                      value: category,
                                      label: ActivityUtils().getCategoryLabel(category),
                                    );
                                  }).toList(),
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedFilterCategory = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Milestone filter (dropdown)
                              DropdownMenu<MilestoneType?>(
                                key: ValueKey(_selectedFilterMilestone),
                                initialSelection: _selectedFilterMilestone,
                                label: const Text('Por hito'),
                                dropdownMenuEntries: MilestoneType.values.map((milestone) {
                                  return DropdownMenuEntry(
                                    value: milestone,
                                    label: ActivityUtils().getMilestoneLabel(milestone),
                                  );
                                }).toList(),
                                onSelected: (value) {
                                  setState(() {
                                    _selectedFilterMilestone = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Filter and clean filter buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.black
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    _selectedFilterTitle = '';
                                    _filterTitleController.clear();
                                    _selectedFilterCategory = null;
                                    _selectedFilterMilestone = null;
                                  });
                                },
                                label: const Text('Limpiar filtros'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
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
                    return const Center(child: Text("No hay actividades aún"));
                  }

                  // Filters user's activity list by the selected date
                  final allActivities = snapshot.data!;
                  final visibleActivities = allActivities.where((activity) {
                    final matchesDate = ActivityUtils().isActivityForSelectedDate(activity, _selectedDate);
                    final matchesTitle =
                        _selectedFilterTitle.isEmpty || activity.title.toLowerCase().contains(_selectedFilterTitle.toLowerCase());
                    final matchesCategory =
                        _selectedFilterCategory == null || activity.category == _selectedFilterCategory;
                    final matchesMilestone =
                        _selectedFilterMilestone == null || activity.milestone == _selectedFilterMilestone;

                    return matchesDate && matchesTitle && matchesCategory && matchesMilestone;
                  }).toList();

                  // No activities for the selected date
                  if (visibleActivities.isEmpty) {
                    return const Center(child: Text("No hay actividades para este día"));
                  }

                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final scheduledDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

                  ActivityService().saveActivitiesSummaryForWidget(visibleActivities, today);
                  HomeWidget.updateWidget(name: 'ScheduledActivitiesWidget');

                  // List view for every activity
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: visibleActivities.length,
                    itemBuilder: (context, index) {
                      final activity = visibleActivities[index];

                      // Sets the broken streaks to 0
                      ActivityService().checkAndResetBrokenStreak(activity);

                      // Schedules the reminder for the activity
                      if (!scheduledDate.isBefore(today) && activity.reminder && activity.reminderTime != null) {
                        final timeParts = activity.reminderTime!.split(':');

                        NotificationService().scheduleNotification(
                          id: NotificationService().generateNotificationId(activity.id, _selectedDate),
                          title: activity.title,
                          body: '¡Recuerda completar esta actividad antes de que acabe el día!',
                          year: _selectedDate.year,
                          month: _selectedDate.month,
                          day: _selectedDate.day,
                          hour: int.parse(timeParts[0]),
                          minute: int.parse(timeParts[1]),
                        );
                      }

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
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.radio_button_unchecked,
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
                                    const Icon(Icons.donut_large_rounded, size: 20),
                                    const SizedBox(height: 2),
                                    Text('${progress.progressQuantity} / ${activity.quantity}'),
                                  ],
                                ),
                              );
                              break;

                            case MilestoneType.timed:
                              final remainingDuration = Duration(
                                hours: progress.remainingHours ?? activity.durationHours!,
                                minutes: progress.remainingMinutes ?? activity.durationMinutes!,
                                seconds: progress.remainingSeconds ?? activity.durationSeconds!,
                              );

                              trailing = SizedBox(
                                height: 50,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 20),
                                    const SizedBox(height: 2),
                                    Text(ActivityUtils().formatDuration(remainingDuration)),
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
                              final progressDate = DateFormat('dd-MM-yyyy').parse(progress.date);

                              if (progress.completed) {
                                return Colors.green.shade800;
                              } else if (progressDate.isBefore(DateTime(today.year, today.month, today.day))) {
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
                                  final progressDate = DateFormat('dd-MM-yyyy').parse(progress.date);

                                  if (progress.completed) {
                                    return Colors.green.shade800;
                                  } else if (progressDate.isBefore(DateTime(today.year, today.month, today.day))) {
                                    return Colors.red.shade500;
                                  } else {
                                    return Colors.grey.shade700;
                                  }
                                }(),
                                width: 2,
                              ),
                            ),

                            child: ListTile(
                              leading: Icon(ActivityUtils().getCategoryIcon(activity.category)),
                              title: Row(
                                children: [
                                  if (activity.type == ActivityType.challenge) ...[
                                    const Icon(Icons.emoji_events_rounded, size: 20),
                                    const SizedBox(width: 6),
                                  ],
                                  Flexible(
                                    child: Text(
                                      activity.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: activity.description != null && activity.description!.isNotEmpty
                                  ? Text(activity.description!)
                                  : null,
                              trailing: trailing,

                              // Open Activity details
                              onTap: () {
                                Navigator.pushNamed(context, '/activityDetails', arguments: activity.id);
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
                                    builder: (context) => ProgressDialog(activity: activity, progress: progress),
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
                        decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Options: custom and with template
                    ListTile(
                      leading: const Icon(Icons.note_add),
                      title: const Text('Actividad personalizada'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/createActivity');
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.edit_document),
                      title: const Text('Plantillas de actividades'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/selectTemplateActivity');
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
}

// Checks if the parameter date is today
bool _isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month && date.day == now.day;
}
