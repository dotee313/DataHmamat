import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'l10n.dart';
import 'models.dart';
import 'storage.dart';
import 'widgets.dart';

/// لوحة إحصائيات بصرية مكتوبة بالكامل محلياً من سجلات الجهاز.
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String? _birdId;

  List<String> get _monthLabels {
    final now = DateTime.now();
    return List<String>.generate(6, (i) {
      final month = DateTime(now.year, now.month - (5 - i), 1);
      return '${month.month}/${month.year.toString().substring(2)}';
    });
  }

  List<double> _monthlyEggs() {
    final months = _monthLabels;
    final values = List<double>.filled(6, 0);
    for (final clutch in Store.instance.clutches) {
      for (var i = 0; i < months.length; i++) {
        final parts = months[i].split('/');
        if (clutch.hatchDue.year == int.parse('20${parts[1]}') &&
            clutch.hatchDue.month == int.parse(parts[0])) {
          values[i] += clutch.hatchedCount;
          break;
        }
      }
    }
    return values;
  }

  List<double> _monthlyExpenses() {
    final months = _monthLabels;
    final values = List<double>.filled(6, 0);
    for (final expense in Store.instance.expenses) {
      for (var i = 0; i < months.length; i++) {
        final parts = months[i].split('/');
        if (expense.date.year == int.parse('20${parts[1]}') &&
            expense.date.month == int.parse(parts[0])) {
          values[i] += expense.amount;
          break;
        }
      }
    }
    return values;
  }

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;
    final birds = store.birds;
    final selected = store.find(_birdId) ?? (birds.isEmpty ? null : birds.first);
    final weights = <WeightRecord>[
      if (selected != null)
        ...store.weights.where((w) => w.birdId == selected.id),
    ]..sort((a, b) => a.date.compareTo(b.date));
    final spots = <FlSpot>[];
    for (var i = 0; i < weights.length && i < 30; i++) {
      spots.add(FlSpot(i.toDouble(), weights[i].grams));
    }
    final eggs = _monthlyEggs();
    final expenses = _monthlyExpenses();

    return Scaffold(
      appBar: AppBar(title: Text(S.stats)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: S.weightTrend,
            icon: Icons.monitor_weight_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (birds.isEmpty)
                  Text(S.noStats,
                      style: const TextStyle(fontSize: 12, color: AppTheme.muted))
                else
                  DropdownButtonFormField<String>(
                    initialValue: selected?.id,
                    decoration: InputDecoration(labelText: S.name),
                    items: [
                      for (final bird in birds)
                        DropdownMenuItem<String>(
                            value: bird.id, child: Text(bird.name)),
                    ],
                    onChanged: (v) => setState(() => _birdId = v),
                  ),
                const SizedBox(height: 12),
                if (spots.isEmpty)
                  Text(S.noStats,
                      style: const TextStyle(fontSize: 12, color: AppTheme.muted))
                else
                  SizedBox(height: 190, child: _line(spots)),
              ],
            ),
          ),
          SectionCard(
            title: S.eggProduction,
            icon: Icons.egg_outlined,
            child: eggs.every((v) => v == 0)
                ? Text(S.noStats,
                    style: const TextStyle(fontSize: 12, color: AppTheme.muted))
                : SizedBox(height: 190, child: _bars(eggs, AppTheme.gold)),
          ),
          SectionCard(
            title: S.monthlyExpenses,
            icon: Icons.account_balance_wallet_outlined,
            child: expenses.every((v) => v == 0)
                ? Text(S.noStats,
                    style: const TextStyle(fontSize: 12, color: AppTheme.muted))
                : SizedBox(height: 190, child: _bars(expenses, AppTheme.purple)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              S.lastSixMonths,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppTheme.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(List<FlSpot> spots) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.purple,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 42),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _bars(List<double> values, Color color) {
    final labels = _monthLabels;
    return BarChart(
      BarChartData(
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: color,
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 34),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    labels[index],
                    style: const TextStyle(fontSize: 9, color: AppTheme.muted),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
