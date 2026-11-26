import 'package:flutter/material.dart';

import 'l10n.dart';
import 'models.dart';
import 'storage.dart';
import 'theme.dart';

class BirdFormPage extends StatefulWidget {
  const BirdFormPage({super.key, this.bird});

  final Bird? bird;

  @override
  State<BirdFormPage> createState() => _BirdFormPageState();
}

class _BirdFormPageState extends State<BirdFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _kind = TextEditingController();
  final _color = TextEditingController();
  final _ring = TextEditingController();
  final _cv = TextEditingController();

  late String _sex;
  late DateTime _bornOn;
  late int _birthWeek;
  late int _birthMonth;
  late int _birthYear;
  String? _father;
  String? _mother;
  String? _eggPartner;
  int? _eggGeneration;
  String? _oldEggPartner;
  late bool _reminders;
  late bool _alive;
  final Set<String> _selectedTraits = <String>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final b = widget.bird;
    _name.text = b?.name ?? '';
    _kind.text = b?.kind ?? '';
    _color.text = b?.color ?? '';
    _ring.text = b?.ring ?? '';
    _cv.text = b?.cv ?? '';
    _sex = b?.sex ?? 'ذكر';
    _bornOn = b?.bornOn ?? DateTime.now();
    _birthWeek = _weekOf(_bornOn);
    _birthMonth = _bornOn.month;
    _birthYear = _bornOn.year < 1990 ? 1990 : _bornOn.year;
    _father = b?.fatherId;
    _mother = b?.motherId;
    _eggPartner = b?.eggPartnerId;
    _oldEggPartner = b?.eggPartnerId;
    _eggGeneration = b?.eggGeneration;
    _selectedTraits.addAll(
      (b?.traits ?? <String>[]).where((t) => S.readyTraits.contains(t)),
    );
    _reminders = b?.reminders ?? true;
    _alive = b?.alive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _kind.dispose();
    _color.dispose();
    _ring.dispose();
    _cv.dispose();
    super.dispose();
  }

  static int _weekOf(DateTime date) =>
      ((date.day - 1) ~/ 7).clamp(0, 4).toInt() + 1;

  DateTime _dateFromInputs() {
    final lastDay = DateTime(_birthYear, _birthMonth + 1, 0).day;
    final day = ((_birthWeek - 1) * 7 + 1).clamp(1, lastDay).toInt();
    return DateTime(_birthYear, _birthMonth, day);
  }

  void _setBirth({int? week, int? month, int? year}) {
    setState(() {
      if (week != null) _birthWeek = week;
      if (month != null) _birthMonth = month;
      if (year != null) _birthYear = year;
      _bornOn = _dateFromInputs();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    final old = widget.bird;
    final now = DateTime.now();
    final bird = Bird(
      id: old?.id ?? now.microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      kind: _kind.text.trim(),
      color: _color.text.trim(),
      sex: _sex,
      ring: _ring.text.trim(),
      cv: _cv.text.trim(),
      fatherId: _father,
      motherId: _mother,
      bornOn: _bornOn,
      lastPhotoAt: old?.lastPhotoAt,
      nextPhotoDue: old?.nextPhotoDue ?? now.add(const Duration(days: 7)),
      photos: old?.photos ?? <String>[],
      photoLog: old?.photoLog ?? <String>[],
      reminders: _reminders,
      alive: _alive,
      traits: <String>[
        ...(old?.traits ?? <String>[]).where(
          (t) => !S.readyTraits.contains(t) && !_selectedTraits.contains(t),
        ),
        ...S.readyTraits.where((t) => _selectedTraits.contains(t)),
      ],
      eggPartnerId: _eggPartner,
      eggGeneration: _eggGeneration,
    );

    await Store.instance.upsertBird(bird);

    // الربط متبادل: إذا كان شريك البيضة مسجّلاً يظهر الربط في بطاقته أيضاً.
    if (_oldEggPartner != null && _oldEggPartner != _eggPartner) {
      final previous = Store.instance.find(_oldEggPartner);
      if (previous != null && previous.eggPartnerId == bird.id) {
        await Store.instance.upsertBird(previous.copyWith(
          clearEggPartner: true,
          clearEggGeneration: true,
        ));
      }
    }
    if (_eggPartner != null && _eggPartner != bird.id) {
      final partner = Store.instance.find(_eggPartner);
      if (partner != null) {
        await Store.instance.upsertBird(partner.copyWith(
          eggPartnerId: bird.id,
          eggGeneration: _eggGeneration,
        ));
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(S.saved)));
  }

  @override
  Widget build(BuildContext context) {
    final others = Store.instance.birds
        .where((b) => b.id != widget.bird?.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.bird == null ? S.addBird : S.editBird)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          children: [
            _field(
              controller: _name,
              label: S.name,
              icon: Icons.pets_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? S.name : null,
            ),
            const SizedBox(height: 12),
            _field(controller: _kind, label: S.kind, icon: Icons.category_outlined),
            const SizedBox(height: 12),
            _field(controller: _color, label: S.color, icon: Icons.palette_outlined),
            const SizedBox(height: 8),
            _chipGroup(
              title: S.colorsTitle,
              values: S.readyColors,
              selected: (v) => _color == v,
              onSelected: (v, on) => setState(() => _color = on ? v : ''),
            ),
            const SizedBox(height: 8),
            _chipGroup(
              title: S.marksTitle,
              values: S.readyMarks,
              selected: (v) => _selectedTraits.contains(v),
              onSelected: _toggleTrait,
            ),
            const SizedBox(height: 8),
            _chipGroup(
              title: S.wingBeakTitle,
              values: S.readyWingBeak,
              selected: (v) => _selectedTraits.contains(v),
              onSelected: _toggleTrait,
            ),
            const SizedBox(height: 12),
            _field(controller: _ring, label: S.ring, icon: Icons.numbers_outlined),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _sex,
              decoration: InputDecoration(
                labelText: S.sex,
                prefixIcon: const Icon(Icons.male_outlined),
              ),
              items: [
                DropdownMenuItem<String>(value: 'ذكر', child: Text(S.male)),
                DropdownMenuItem<String>(value: 'أنثى', child: Text(S.female)),
              ],
              onChanged: (v) => setState(() => _sex = v ?? 'ذكر'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<bool>(
              initialValue: _alive,
              decoration: InputDecoration(
                labelText: S.lifeStatus,
                prefixIcon: const Icon(Icons.favorite_outline),
              ),
              items: [
                DropdownMenuItem<bool>(value: true, child: Text(S.alive)),
                DropdownMenuItem<bool>(value: false, child: Text(S.dead)),
              ],
              onChanged: (v) => setState(() => _alive = v ?? true),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppTheme.purple),
                const SizedBox(width: 8),
                Text(
                  S.bornOn,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              S.birthHint,
              style: const TextStyle(fontSize: 10, color: AppTheme.muted),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _birthWeek,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: S.week),
                    items: [
                      for (var i = 1; i <= 5; i++)
                        DropdownMenuItem<int>(
                          value: i,
                          child: Text(
                            S.weekName(i),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) => _setBirth(week: v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _birthMonth,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: S.month),
                    items: [
                      for (var i = 1; i <= 12; i++)
                        DropdownMenuItem<int>(
                          value: i,
                          child: Text(
                            S.monthName(i),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) => _setBirth(month: v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _birthYear,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: S.year),
                    items: [
                      for (var y = DateTime.now().year; y >= 1990; y--)
                        DropdownMenuItem<int>(value: y, child: Text('$y')),
                    ],
                    onChanged: (v) => _setBirth(year: v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _parentField(
              label: S.father,
              value: _father,
              candidates: others,
              onChanged: (v) => setState(() => _father = v),
            ),
            const SizedBox(height: 12),
            _parentField(
              label: S.mother,
              value: _mother,
              candidates: others,
              onChanged: (v) => setState(() => _mother = v),
            ),
            const SizedBox(height: 12),
            _parentField(
              label: S.eggPartner,
              value: _eggPartner,
              candidates: others,
              onChanged: (v) => setState(() => _eggPartner = v),
            ),
            if (_eggPartner != null) ...[
              const SizedBox(height: 4),
              Text(
                S.eggPartnerHint,
                style: const TextStyle(fontSize: 10, color: AppTheme.muted),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                initialValue: _eggGeneration,
                isExpanded: true,
                decoration: InputDecoration(labelText: S.generation),
                items: [
                  DropdownMenuItem<int?>(value: null, child: Text(S.none)),
                  for (var i = 1; i <= 10; i++)
                    DropdownMenuItem<int?>(
                      value: i,
                      child: Text(S.generationLabel(i)),
                    ),
                ],
                onChanged: (v) => setState(() => _eggGeneration = v),
              ),
            ],
            const SizedBox(height: 14),
            TextFormField(
              controller: _cv,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: S.cv,
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _reminders,
              onChanged: (v) => setState(() => _reminders = v),
              title: Text(S.reminders),
              subtitle: Text(S.remindersSub),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: Text(_busy ? S.save : S.save),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTrait(String value, bool selected) {
    setState(() {
      if (selected) {
        _selectedTraits.add(value);
      } else {
        _selectedTraits.remove(value);
      }
    });
  }

  Widget _chipGroup({
    required String title,
    required List<String> values,
    required bool Function(String) selected,
    required void Function(String, bool) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: -2,
          children: [
            for (final value in values)
              FilterChip(
                label: Text(
                  value,
                  style: const TextStyle(fontSize: 11),
                ),
                selected: selected(value),
                showCheckmark: false,
                onSelected: (on) => onSelected(value, on),
              ),
          ],
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _parentField({
    required String label,
    required String? value,
    required List<Bird> candidates,
    required ValueChanged<String?> onChanged,
  }) {
    final items = <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(value: null, child: Text(S.none)),
      ...candidates.map(
        (b) => DropdownMenuItem<String?>(value: b.id, child: Text(b.name)),
      ),
    ];
    return DropdownButtonFormField<String?>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.family_restroom_outlined),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
