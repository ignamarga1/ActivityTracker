import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/models/activity_progress.dart';
import 'package:activity_tracker_flutter/services/activity_progress_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ChartView { week, month, quarter }

class ActivityProgressChart extends StatefulWidget {
  final Activity activity;

  const ActivityProgressChart({super.key, required this.activity});

  @override
  State<ActivityProgressChart> createState() => _ActivityProgressChartState();
}

class _ActivityProgressChartState extends State<ActivityProgressChart> {
  ChartView _selectedView = ChartView.week;
  DateTime _focusedDate = DateTime.now();
  List<ActivityProgress> _progressList = [];
  double? _maxYOverride;

  @override
  void initState() {
    super.initState();
    _loadActivityProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _viewSelectorChip('Semana', ChartView.week),
            _viewSelectorChip('Mes', ChartView.month),
            _viewSelectorChip('Trimestre', ChartView.quarter),
          ],
        ),
        const SizedBox(height: 8),
        
        // Date selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: _goToPreviousPeriod, icon: const Icon(Icons.chevron_left)),
            Text(
              _selectedView == ChartView.week
                  ? 'Semana del ${DateFormat('d MMM', "es").format(_focusedDate.subtract(Duration(days: _focusedDate.weekday - 1)))}'
                  : _selectedView == ChartView.month
                  ? 'Año ${_focusedDate.year}'
                  : 'Año ${_focusedDate.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(onPressed: _goToNextPeriod, icon: const Icon(Icons.chevron_right)),
          ],
        ),
        const SizedBox(height: 16),

        AspectRatio(
          aspectRatio: 1.25,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _buildChart()),
        ),
      ],
    );
  }

  // Stores all the activity progress of the activity in a list
  Future<void> _loadActivityProgress() async {
    final allProgress = await ActivityProgressService().getAllProgressForActivity(widget.activity.id);
    setState(() => _progressList = allProgress);
  }

  // Normalizes the date
  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  // Calculates the value of the activity progress depending on the milestone type
  double calculateProgressValue(ActivityProgress progress) {
    switch (widget.activity.milestone) {
      case MilestoneType.yesNo:
        return progress.completed ? 1 : 0;
      case MilestoneType.quantity:
        return (progress.progressQuantity ?? 0).toDouble();
      case MilestoneType.timed:
        final total =
            (widget.activity.durationHours ?? 0) * 3600 +
            (widget.activity.durationMinutes ?? 0) * 60 +
            (widget.activity.durationSeconds ?? 0);
        final remaining =
            (progress.remainingHours ?? 0) * 3600 +
            (progress.remainingMinutes ?? 0) * 60 +
            (progress.remainingSeconds ?? 0);
        return (total - remaining).clamp(0, total).toDouble();
    }
  }

  // Formats the time duration (used in the week chartview of timed activities)
  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  // Builds the activity progress chart
  // Week: progress based on the goal
  // Month and Quarter: progress based on the number of completed days
  Widget _buildChart() {
    final chartData = _buildChartData();

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: chartData,
        barTouchData: BarTouchData(enabled: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

          // Left titles
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) {
                if (widget.activity.milestone == MilestoneType.timed && _selectedView == ChartView.week) {
                  return Text(formatDuration(value.toInt()), style: const TextStyle(fontSize: 10));
                } else {
                  return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                }
              },
            ),
          ),

          // Bottom titles
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(dataLabel(value.toInt()), style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Builds the bars of the chart based on the activity progress
  List<BarChartGroupData> _buildChartData() {
    final now = _focusedDate;
    final Map<String, double> dataMap = {};
    final List<String> labels = [];

    switch (_selectedView) {
      // Week
      case ChartView.week:
        final start = now.subtract(Duration(days: now.weekday - 1));
        for (int i = 0; i < 7; i++) {
          final date = normalize(start.add(Duration(days: i)));
          final label = DateFormat.E('es').format(date);
          final progress = _progressList.firstWhere(
            (p) => normalize(DateFormat('dd-MM-yyyy').parse(p.date)) == date,
            orElse: () =>
                ActivityProgress(id: '', activityId: '', createdAt: Timestamp.now(), completed: false, date: ''),
          );
          dataMap[label] =
              (progress.date.isNotEmpty && ActivityUtils().isActivityForSelectedDate(widget.activity, date))
              ? calculateProgressValue(progress)
              : 0;
          labels.add(label);
        }
        break;

      // Month
      case ChartView.month:
        for (int i = 1; i <= 12; i++) {
          final monthLabel = DateFormat.MMM('es').format(DateTime(0, i));
          final count = _progressList
              .where((p) {
                final date = DateFormat('dd-MM-yyyy').parse(p.date);
                return date.month == i && date.year == now.year && p.completed;
              })
              .length
              .toDouble();
          dataMap[monthLabel] = count;
          labels.add(monthLabel);
        }
        break;

      // Quarter
      case ChartView.quarter:
        for (int q = 1; q <= 4; q++) {
          final startMonth = (q - 1) * 3 + 1;
          final endMonth = startMonth + 2;
          final label = 'T$q';
          final count = _progressList
              .where((p) {
                final date = DateFormat('dd-MM-yyyy').parse(p.date);
                return date.year == now.year && date.month >= startMonth && date.month <= endMonth && p.completed;
              })
              .length
              .toDouble();
          dataMap[label] = count;
          labels.add(label);
        }
        break;
    }

    // Adjusts Y axis for month and quarter
    if (_selectedView != ChartView.week) {
      _maxYOverride = dataMap.values.isEmpty ? 1 : dataMap.values.reduce((a, b) => a > b ? a : b);
    } else {
      _maxYOverride = null;
    }

    int i = 0;
    return dataMap.entries.map((entry) {
      return BarChartGroupData(
        x: i++,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Theme.of(context).colorScheme.primary,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  // Returns the max value of Y axis depending on the milestone type
  double get maxY {
    if (_maxYOverride != null) return _maxYOverride!.clamp(1, double.infinity);

    switch (widget.activity.milestone) {
      case MilestoneType.yesNo:
        return 1;
      case MilestoneType.quantity:
        return (widget.activity.quantity ?? 1).toDouble();
      case MilestoneType.timed:
        return ((widget.activity.durationHours ?? 0) * 3600 +
                (widget.activity.durationMinutes ?? 0) * 60 +
                (widget.activity.durationSeconds ?? 0))
            .clamp(1, double.infinity)
            .toDouble();
    }
  }

  // Formats the data labels for the different ChartViews
  String dataLabel(int index) {
    switch (_selectedView) {
      case ChartView.week:
        return ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][index];
      case ChartView.month:
        return DateFormat.MMM('es').format(DateTime(0, index + 1));
      case ChartView.quarter:
        return 'T${index + 1}';
    }
  }

  // Sets the chart to the previous period
  void _goToPreviousPeriod() {
    setState(() {
      if (_selectedView == ChartView.week) {
        _focusedDate = _focusedDate.subtract(const Duration(days: 7));
      } else if (_selectedView == ChartView.month) {
        _focusedDate = DateTime(_focusedDate.year - 1, _focusedDate.month);
      } else if (_selectedView == ChartView.quarter) {
        _focusedDate = DateTime(_focusedDate.year - 1);
      }
    });
  }

  // Sets the chart to the next period
  void _goToNextPeriod() {
    setState(() {
      if (_selectedView == ChartView.week) {
        _focusedDate = _focusedDate.add(const Duration(days: 7));
      } else if (_selectedView == ChartView.month) {
        _focusedDate = DateTime(_focusedDate.year + 1, _focusedDate.month);
      } else if (_selectedView == ChartView.quarter) {
        _focusedDate = DateTime(_focusedDate.year + 1);
      }
    });
  }

  // Choice chip format options for ChartView
  Widget _viewSelectorChip(String label, ChartView view) {
    return ChoiceChip(
      showCheckmark: false,
      label: Text(label),
      selected: _selectedView == view,
      onSelected: (_) => setState(() => _selectedView = view),
      selectedColor: Theme.of(context).colorScheme.primary,
    );
  }
}
