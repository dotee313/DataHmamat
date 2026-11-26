import 'package:flutter/material.dart';

import 'family_tree.dart';
import 'l10n.dart';
import 'models.dart';
import 'storage.dart';
import 'theme.dart';
import 'type_form.dart';
import 'widgets.dart';

/// تزويج اختباري: طيران موجودان أو نوعان مكتوبان أو واحد من كلٍّ.
class TestMatingPage extends StatefulWidget {
  const TestMatingPage({super.key});

  @override
  State<TestMatingPage> createState() => _TestMatingPageState();
}

class _Prediction {
  const _Prediction(this.label, this.chance);

  final String label;
  final double chance;
}

class _TestMatingPageState extends State<TestMatingPage> {
  String? _first;
  String? _second;
  List<_Prediction> _predictions = <_Prediction>[];
  bool _calculated = false;

  List<DropdownMenuItem<String>> get _options => <DropdownMenuItem<String>>[
        const DropdownMenuItem<String>(value: null, child: Text('—')),
        for (final b in Store.instance.birds)
          DropdownMenuItem<String>(
            value: 'bird:${b.id}',
            child: Text(b.name),
          ),
        for (final t in Store.instance.types)
          DropdownMenuItem<String>(
            value: 'type:${t.id}',
            child: Text('${S.virtualBird}: ${t.name}'),
          ),
      ];

  Bird? _resolve(String? key) {
    if (key == null) return null;
    if (key.startsWith('type:')) {
      return Store.instance.findType(key.substring(5));
    }
    if (key.startsWith('bird:')) {
      return Store.instance.find(key.substring(5));
    }
    return null;
  }

  /// تقدير مبسيّط: اللون من الطرفين، وكل صفة موجودة عند أحدهما
  /// احتمالها ٥٠٪، وعند الطرفين احتمالها ١٠٠٪.
  List<_Prediction> _predict(Bird a, Bird b) {
    final result = <_Prediction>[];
    final ca = a.color.trim();
    final cb = b.color.trim();
    if (ca.isEmpty && cb.isNotEmpty) {
      result.add(_Prediction(cb, 1));
    } else if (cb.isEmpty && ca.isNotEmpty) {
      result.add(_Prediction(ca, 1));
    } else if (ca.isNotEmpty && cb.isNotEmpty) {
      if (ca == cb) {
        result.add(_Prediction(ca, 1));
      } else {
        result.add(_Prediction(ca, 0.5));
        result.add(_Prediction(cb, 0.5));
      }
    }
    for (final trait in S.readyTraits) {
      final inA = a.traits.contains(trait);
      final inB = b.traits.contains(trait);
      if (inA || inB) {
        result.add(_Prediction(trait, inA && inB ? 1 : 0.5));
      }
    }
    result.sort((x, y) => y.chance.compareTo(x.chance));
    return result;
  }

  void _calculate() {
    final a = _resolve(_first);
    final b = _resolve(_second);
    setState(() {
      _calculated = true;
      _predictions = (a == null || b == null) ? <_Prediction>[] : _predict(a, b);
    });
  }

  Future<void> _addVirtual() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const TypeFormPage()),
    );
    if (!mounted) return;
    setState(() {});
  }

  Widget _parentCard(String? key) {
    final bird = _resolve(key);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.purple.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.purple.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          BirdCircle(bird: bird, diameter: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bird?.name ?? S.notRegistered,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  <String>[
                    if (bird != null && bird.color.isNotEmpty) bird.color,
                    if (bird != null) (bird.alive ? S.alive : S.dead),
                    if (bird?.isVirtual ?? false) S.virtualBird,
                  ].join(' • '),
                  style: const TextStyle(fontSize: 10, color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String label, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.compare_arrows_outlined),
      ),
      items: _options,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.testMating)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: S.testMating,
            icon: Icons.biotech_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.testMatingSub,
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                ),
                const SizedBox(height: 12),
                _dropdown(
                  S.selectFirstParent,
                  _first,
                  (v) => setState(() {
                    _first = v;
                    _calculated = false;
                  }),
                ),
                const SizedBox(height: 10),
                _parentCard(_first),
                const SizedBox(height: 14),
                _dropdown(
                  S.selectSecondParent,
                  _second,
                  (v) => setState(() {
                    _second = v;
                    _calculated = false;
                  }),
                ),
                const SizedBox(height: 10),
                _parentCard(_second),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _addVirtual,
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(S.addType),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate_outlined),
                  label: Text(S.calculate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: S.expectedTraits,
            icon: Icons.palette_outlined,
            child: !_calculated
                ? Text(
                    S.chooseTwoParents,
                    style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                  )
                : _predictions.isEmpty
                    ? Text(
                        S.noPrediction,
                        style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                      )
                    : Column(
                        children: [
                          for (final p in _predictions)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.label,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: LinearProgressIndicator(
                                      value: p.chance,
                                      minHeight: 8,
                                      color: AppTheme.purple,
                                      backgroundColor:
                                          AppTheme.purple.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 42,
                                    child: Text(
                                      '${(p.chance * 100).round()}%',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.purple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
          ),
          const SizedBox(height: 8),
          Text(
            S.testMatingHint,
            style: const TextStyle(fontSize: 10, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}
