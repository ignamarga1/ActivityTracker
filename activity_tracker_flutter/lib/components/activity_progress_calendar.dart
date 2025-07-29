import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/services/activity_progress_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ActivityProgressCalendar extends StatefulWidget {
  final Activity activity;

  const ActivityProgressCalendar({super.key, required this.activity});

  @override
  State<ActivityProgressCalendar> createState() => _ActivityProgressCalendarState();
}

class _ActivityProgressCalendarState extends State<ActivityProgressCalendar> {
  DateTime focusedDay = DateTime.now();
  Map<String, bool> completedDays = {};
  late List<DateTime> scheduledDates;
  CalendarFormat calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _loadActivityProgress();
  }

  // Normalizes the date
  DateTime normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _formatChip('Mes', CalendarFormat.month),
              _formatChip('2 semanas', CalendarFormat.twoWeeks),
              _formatChip('Semana', CalendarFormat.week),
            ],
          ),
        ),

        TableCalendar(
          // Calendar configuration
          focusedDay: focusedDay,
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          calendarFormat: calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'es_ES',

          // Styles
          calendarStyle: const CalendarStyle(outsideDaysVisible: false),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: Theme.of(context).brightness == Brightness.dark
                ? TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                : TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: Theme.of(context).brightness == Brightness.dark
                ? TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                : TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            weekendStyle: Theme.of(context).brightness == Brightness.dark
                ? TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                : TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),

          // Builders
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, _) => _buildDay(day),
            todayBuilder: (context, day, _) => _buildDay(day, isToday: true),
            outsideBuilder: (context, day, _) => const SizedBox.shrink(),
          ),

          // On change
          onPageChanged: (day) {
            setState(() => focusedDay = day);
          },

          onFormatChanged: (format) {
            setState(() {
              calendarFormat = format;
            });
          },
        ),
      ],
    );
  }

  // Stores all the activity progress of the activity in a map (date : completed)
  Future<void> _loadActivityProgress() async {
    final allProgress = await ActivityProgressService().getAllProgressForActivity(widget.activity.id);

    setState(() {
      completedDays = {
        for (var p in allProgress) DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(p.date)): p.completed,
      };
    });
  }

  // Day builder (changes the appearence based in the day and its progress)
  Widget _buildDay(DateTime day, {bool isToday = false}) {
    final normalizedDay = normalizeDate(day);
    final dayKey = DateFormat('yyyy-MM-dd').format(normalizedDay);
    final isScheduledDay = ActivityUtils().isActivityForSelectedDate(widget.activity, normalizedDay);

    final isFuture = normalizedDay.isAfter(normalizeDate(DateTime.now()));
    final isCompleted = completedDays[dayKey] == true;

    Color? bgColor;
    Color? textColor;
    BoxBorder? border;

    // Days that aren't scheduled for the activity (color to look inactive)
    if (!isScheduledDay) {
      return Container(
        margin: const EdgeInsets.all(6),
        alignment: Alignment.center,
        child: Text('${day.day}', style: TextStyle(color: Colors.grey.shade700)),
      );
    }

    // Format depending on the completion status
    if (isCompleted) {
      bgColor = Colors.green.shade800;
    } else if (isToday) {
      bgColor = Theme.of(context).colorScheme.primary;
      textColor = Colors.white;
      border = Border.all(color: Theme.of(context).colorScheme.primary, width: 2);
    } else if (isFuture) {
      bgColor = Colors.grey.shade400;
      textColor = Colors.white;
    } else {
      bgColor = Colors.red.shade500;
    }

    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor, border: border),
      child: Text(
        '${day.day}',
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  // Choice chip format options for CalendarFormat
  Widget _formatChip(String label, CalendarFormat format) {
    final isSelected = calendarFormat == format;

    return ChoiceChip(
      showCheckmark: false,
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary,
      onSelected: (_) {
        setState(() {
          calendarFormat = format;
        });
      },
    );
  }
}
