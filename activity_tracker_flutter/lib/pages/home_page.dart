import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
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
    if (user == null) return const SizedBox.shrink(); // o loading indicator

    return Scaffold(
      // Appbar with current selected date
      appBar: AppBar(
        title: DateUtils.isSameDay(_selectedDate, DateTime.now())
            ? const Text('Hoy')
            : Text(DateFormat.yMMMMd('es_ES').format(_selectedDate), style: TextStyle(fontSize: 20),),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),

      // Datetime picker and list of activities for the day
      // EasyDatetimePicker
      body: EasyTheme(
        data: EasyTheme.of(context).copyWithState(
          selectedCurrentDayTheme: DayThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),

          unselectedCurrentDayTheme: DayThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),

          unselectedDayTheme: DayThemeData(
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
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: GestureDetector(
                  onTap: onTap,
                  child: const Icon(Icons.calendar_month, size: 25,),
                ),
              );
            },
          ),
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
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
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
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.note_add),
                      title: const Text('Actividad con plantilla'),
                      onTap: () async {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
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
