import 'package:flutter/material.dart';

import 'l10n.dart';
import 'models.dart';
import 'storage.dart';
import 'theme.dart';
import 'widgets.dart';

/// تقويم شهري يجمع المواعيد المخصصة مع مواعيد الصور والفقس والصحة تلقائياً.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.onChanged});

  final VoidCallback onChanged;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _selected = DateTime(now.year, now.month, now.day);
  }

  List<CalendarEvent> _dayEvents(DateTime day) {
    final store = Store.instance;
    final result = <CalendarEvent>[
      ...store.events.where((e) => sameDay(e.date, day)),
    ];
    for (final bird in store.birds) {
      final due = bird.nextPhotoDue;
      if (bird.reminders && due != null && sameDay(due, day)) {
        result.add(CalendarEvent(
          id: 'photo_${bird.id}',
          title: '${S.photoEvent}: ${bird.name}',
          date: due,
          type: 'photo',
          birdId: bird.id,
        ));
      }
    }
    for (final clutch in store.clutches) {
      if (sameDay(clutch.hatchDue, day)) {
        result.add(CalendarEvent(
          id: 'hatch_${clutch.id}',
          title: '${S.hatchEvent}: ${store.find(clutch.motherId)?.name ?? S.unknown}',
          date: clutch.hatchDue,
          type: 'hatch',
        ));
      }
    }
    for (final health in store.health) {
      final due = health.nextDue;
      if (due != null && sameDay(due, day)) {
        result.add(CalendarEvent(
          id: 'health_${health.id}',
          title: '${S.healthEvent}: ${store.find(health.birdId)?.name ?? S.unknown}',
          date: due,
          type: 'health',
          birdId: health.birdId,
        ));
      }
    }
    return result;
  }

  Future<void> _add() async {
    final title = TextEditingController();
    var date = DateTime(_selected.year, _selected.month, _selected.day);
    var type = 'custom';
    String? birdId;
    final birds = Store.instance.birds;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(S.addEvent),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: InputDecoration(labelText: S.eventTitle),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${S.date}: ${formatDate(date)}'),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setDialog(() => date = picked);
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: InputDecoration(labelText: S.eventType),
                  items: [
                    DropdownMenuItem<String>(
                        value: 'custom', child: Text(S.customEvent)),
                    DropdownMenuItem<String>(
                        value: 'health', child: Text(S.healthEvent)),
                  ],
                  onChanged: (v) => setDialog(() => type = v ?? type),
                ),
                if (birds.isNotEmpty)
                  DropdownButtonFormField<String?>(
                    initialValue: birdId,
                    decoration: InputDecoration(labelText: S.eventForBird),
                    items: [
                      DropdownMenuItem<String?>(
                          value: null, child: Text(S.none)),
                      ...birds.map(
                        (b) => DropdownMenuItem<String?>(
                            value: b.id, child: Text(b.name)),
                      ),
                    ],
                    onChanged: (v) => setDialog(() => birdId = v),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(S.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(S.save),
            ),
          ],
        ),
      ),
    );
    if (ok != true || title.text.trim().isEmpty) return;
    await Store.instance.addEvent(CalendarEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.text.trim(),
      date: date,
      type: type,
      birdId: birdId ?? '',
    ));
    setState(() {
      _month = DateTime(date.year, date.month, 1);
      _selected = date;
    });
    widget.onChanged();
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta, 1);
      final day = _selected.day;
      final maxDay = DateTime(_month.year, _month.month + 1, 0).day;
      _selected = DateTime(_month.year, _month.month, day > maxDay ? maxDay : day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekdays = L.isAr
        ? <String>['أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت']
        : <String>['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final firstOffset = _month.weekday % 7;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final cells = <Widget>[
      for (var i = 0; i < firstOffset; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _dayCell(DateTime(_month.year, _month.month, day)),
    ];
    final selectedEvents = _dayEvents(_selected);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.calendarPage),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            tooltip: S.today,
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _month = DateTime(now.year, now.month, 1);
                _selected = DateTime(now.year, now.month, now.day);
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: '${_month.year}/${_month.month.toString().padLeft(2, '0')}',
            icon: Icons.calendar_month_outlined,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _shiftMonth(-1),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _shiftMonth(1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    for (final label in weekdays)
                      Expanded(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.muted,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: cells,
                ),
              ],
            ),
          ),
          SectionCard(
            title: formatDate(_selected),
            icon: Icons.event_note_outlined,
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.purple),
              onPressed: _add,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedEvents.isEmpty)
                  Text(S.noEvents,
                      style: const TextStyle(fontSize: 12, color: AppTheme.muted))
                else
                  for (final event in selectedEvents)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        event.type == 'photo'
                            ? Icons.photo_camera_outlined
                            : event.type == 'hatch'
                                ? Icons.egg_outlined
                                : event.type == 'health'
                                    ? Icons.medical_services_outlined
                                    : Icons.event_outlined,
                        color: event.type == 'photo'
                            ? AppTheme.gold
                            : AppTheme.purple,
                        size: 18,
                      ),
                      title: Text(event.title),
                      trailing: event.isCustom
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () async {
                                await Store.instance.removeEvent(event.id);
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                const SizedBox(height: 8),
                Text(S.derivedEvents,
                    style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: AppTheme.purple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _dayCell(DateTime day) {
    final isSelected = sameDay(day, _selected);
    final isToday = sameDay(day, DateTime.now());
    final hasEvents = _dayEvents(day).isNotEmpty;
    return InkWell(
      onTap: () => setState(() => _selected = day),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.purple.withValues(alpha: 0.16)
              : isToday
                  ? AppTheme.gold.withValues(alpha: 0.16)
                  : null,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: AppTheme.purple) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppTheme.purple : AppTheme.ink,
              ),
            ),
            if (hasEvents)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppTheme.gold,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
