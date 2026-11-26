import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'l10n.dart';
import 'models.dart';
import 'storage.dart';
import 'theme.dart';

/// نوع أو حمامة افتراضية تُحفظ separate عن طيوري، وتُستخدم في التزويج الاختباري.
class TypeFormPage extends StatefulWidget {
  const TypeFormPage({super.key, this.type});

  final Bird? type;

  @override
  State<TypeFormPage> createState() => _TypeFormPageState();
}

class _TypeFormPageState extends State<TypeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _color = TextEditingController();

  late final String _id;
  late String _sex;
  final List<String> _photos = <String>[];
  final Set<String> _selectedTraits = <String>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final t = widget.type;
    _id = t?.id ?? 'type-${DateTime.now().microsecondsSinceEpoch}';
    _name.text = t?.name ?? '';
    _color.text = t?.color ?? '';
    _sex = t?.sex ?? 'ذكر';
    _photos.addAll(t?.photos ?? <String>[]);
    _selectedTraits.addAll(
      (t?.traits ?? <String>[]).where((v) => S.readyTraits.contains(v)),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _color.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final path = await Store.instance.capturePhoto(
      Bird(id: _id, name: _name.text.trim(), photos: _photos),
      source,
    );
    if (path == null || !mounted) return;
    setState(() => _photos.add(path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final type = Bird(
      id: _id,
      name: _name.text.trim(),
      color: _color.text.trim(),
      sex: _sex,
      photos: _photos,
      traits: <String>[
        ...(widget.type?.traits ?? <String>[]).where(
          (t) => !S.readyTraits.contains(t) && !_selectedTraits.contains(t),
        ),
        ...S.readyTraits.where((v) => _selectedTraits.contains(v)),
      ],
      isVirtual: true,
    );
    await Store.instance.upsertType(type);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(S.saved)));
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

  Widget _chipGroup(String title, List<String> values) {
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
                label: Text(value, style: const TextStyle(fontSize: 11)),
                selected: _selectedTraits.contains(value),
                showCheckmark: false,
                onSelected: (on) => _toggleTrait(value, on),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.writeType)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          children: [
            Text(
              S.writeTypeHint,
              style: const TextStyle(fontSize: 11, color: AppTheme.muted),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _name,
              validator: (v) => (v == null || v.trim().isEmpty) ? S.typeName : null,
              decoration: InputDecoration(
                labelText: S.typeName,
                prefixIcon: const Icon(Icons.pets_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _color,
              decoration: InputDecoration(
                labelText: S.color,
                prefixIcon: const Icon(Icons.palette_outlined),
              ),
            ),
            const SizedBox(height: 8),
            _chipGroup(S.colorsTitle, S.readyColors),
            const SizedBox(height: 10),
            _chipGroup(S.marksTitle, S.readyMarks),
            const SizedBox(height: 10),
            _chipGroup(S.wingBeakTitle, S.readyWingBeak),
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
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPhoto(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(S.camera),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPhoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(S.gallery),
                  ),
                ),
              ],
            ),
            if (_photos.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 82,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_photos[i]),
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            size: 36,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          color: Colors.white,
                          onPressed: () => setState(() => _photos.removeAt(i)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: Text(S.save),
            ),
          ],
        ),
      ),
    );
  }
}
