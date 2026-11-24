import 'package:flutter/material.dart';

import 'models.dart';
import 'storage.dart';

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
  String? _father;
  String? _mother;
  late bool _reminders;
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
    _father = b?.fatherId;
    _mother = b?.motherId;
    _reminders = b?.reminders ?? true;
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _bornOn,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      helpText: 'تاريخ الولادة أو الشراء',
    );
    if (picked != null) setState(() => _bornOn = picked);
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
    );

    await Store.instance.upsert(bird);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(old == null ? 'أُضيف الطير' : 'حُفظت التعديلات')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final others = Store.instance.birds
        .where((b) => b.id != widget.bird?.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bird == null ? 'طير جديد' : 'تعديل بيانات الطير'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          children: [
            _field(
              controller: _name,
              label: 'اسم الطير',
              icon: Icons.pets_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'اكتب اسماً للطير' : null,
            ),
            const SizedBox(height: 12),
            _field(
              controller: _kind,
              label: 'النوع / السلالة',
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 12),
            _field(
              controller: _color,
              label: 'اللون',
              icon: Icons.palette_outlined,
            ),
            const SizedBox(height: 12),
            _field(
              controller: _ring,
              label: 'رقم السولة / الحلقة',
              icon: Icons.numbers_outlined,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sex,
                    decoration: const InputDecoration(
                      labelText: 'الجنس',
                      prefixIcon: Icon(Icons.male_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                      DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                    ],
                    onChanged: (v) => setState(() => _sex = v ?? 'ذكر'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'تاريخ الولادة أو الشراء',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(formatDate(_bornOn)),
              ),
            ),
            const SizedBox(height: 14),
            _parentField(
              label: 'الأب',
              value: _father,
              candidates: others,
              onChanged: (v) => setState(() => _father = v),
            ),
            const SizedBox(height: 12),
            _parentField(
              label: 'الأم',
              value: _mother,
              candidates: others,
              onChanged: (v) => setState(() => _mother = v),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _cv,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'السيرة الذاتية للطير (CV)',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _reminders,
              onChanged: (v) => setState(() => _reminders = v),
              title: const Text('تذكير صورة كل أسبوع'),
              subtitle: const Text('يظهر شعار في الواجهة عند موعد الصورة'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: Text(_busy ? 'جارٍ الحفظ...' : 'حفظ'),
            ),
          ],
        ),
      ),
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
      const DropdownMenuItem<String?>(value: null, child: Text('لا يوجد')),
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
