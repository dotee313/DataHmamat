import 'package:flutter/material.dart';

import 'family_tree.dart';
import 'genetics/genetics.dart';
import 'l10n.dart';
import 'models.dart';
import 'storage.dart';
import 'theme.dart';
import 'type_form.dart';
import 'widgets.dart';

/// تزويج اختباري مبني على نموذج UP-Pigen المنقول إلى Dart:
/// طيران موجودان أو نوعان مكتوبان أو واحد من كلٍّ، مع توريث مرتبط بالجنس.
class TestMatingPage extends StatefulWidget {
  const TestMatingPage({super.key});

  @override
  State<TestMatingPage> createState() => _TestMatingPageState();
}

class _TestMatingPageState extends State<TestMatingPage> {
  String? _first;
  String? _second;

  List<PhenotypePrediction> _predictions = <PhenotypePrediction>[];
  bool _calculated = false;
  String? _error;

  Bird? _fatherBird;
  Bird? _motherBird;
  double _maleChance = 0;
  double _femaleChance = 0;
  String _beakLabel = '';
  String _fatherGenotype = '';
  String _motherGenotype = '';
  int _resultCount = 0;

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

  void _calculate() {
    final a = _resolve(_first);
    final b = _resolve(_second);
    if (a == null || b == null) {
      setState(() {
        _calculated = false;
        _error = S.chooseTwoParents;
        _predictions = <PhenotypePrediction>[];
      });
      return;
    }

    // التزويج يحتاج ذكراً وأنثى؛ نحدد الأب والأم تلقائياً من الجنس.
    Bird? father;
    Bird? mother;
    if (sexOf(a) == PigeonSex.male && sexOf(b) == PigeonSex.female) {
      father = a;
      mother = b;
    } else if (sexOf(a) == PigeonSex.female && sexOf(b) == PigeonSex.male) {
      father = b;
      mother = a;
    }
    if (father == null || mother == null) {
      setState(() {
        _calculated = false;
        _error = S.sameSexError;
        _predictions = <PhenotypePrediction>[];
      });
      return;
    }

    final fatherGenotype = genotypeFor(father);
    final motherGenotype = genotypeFor(mother);
    final offspring = cross(fatherGenotype, motherGenotype);
    final ratios = sexRatios(offspring);
    final grouped = summarizeByPhenotype(offspring, limit: 0);

    setState(() {
      _error = null;
      _calculated = true;
      _fatherBird = father;
      _motherBird = mother;
      _predictions = grouped.take(12).toList();
      _resultCount = grouped.length;
      _maleChance = ratios[PigeonSex.male] ?? 0;
      _femaleChance = ratios[PigeonSex.female] ?? 0;
      _beakLabel = expectedBeak(father, mother).lengthClassAr();
      _fatherGenotype = fatherGenotype.toString();
      _motherGenotype = motherGenotype.toString();
    });
  }

  Future<void> _addVirtual() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const TypeFormPage()),
    );
    if (!mounted) return;
    setState(() {});
  }

  Widget _parentCard(String? key, {String? role}) {
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        bird?.name ?? S.notRegistered,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (role != null && role.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.purple.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppTheme.purple,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  <String>[
                    if (bird != null && bird.color.isNotEmpty) bird.color,
                    if (bird != null)
                      (sexOf(bird) == PigeonSex.male ? S.male : S.female),
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

  Widget _genotypeLine(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          '$label: $value',
          style: const TextStyle(fontSize: 9, height: 1.25),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      );

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
                    _error = null;
                  }),
                ),
                const SizedBox(height: 10),
                _parentCard(
                  _first,
                  role: _calculated ? S.father : null,
                ),
                const SizedBox(height: 14),
                _dropdown(
                  S.selectSecondParent,
                  _second,
                  (v) => setState(() {
                    _second = v;
                    _calculated = false;
                    _error = null;
                  }),
                ),
                const SizedBox(height: 10),
                _parentCard(
                  _second,
                  role: _calculated ? S.mother : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final p in _predictions)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${p.sex == PigeonSex.male ? S.male : S.female} • ${p.phenotype}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 96,
                                    child: LinearProgressIndicator(
                                      value: p.chance.clamp(0.0, 1.0).toDouble(),
                                      minHeight: 8,
                                      color: AppTheme.purple,
                                      backgroundColor:
                                          AppTheme.purple.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                          if (_resultCount > _predictions.length)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                S.resultCount(_resultCount),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.muted,
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
          if (_calculated) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: S.geneticBasis,
              icon: Icons.dna_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${S.offspringSexes}: ${S.male} ${(_maleChance * 100).round()}% • '
                    '${S.female} ${(_femaleChance * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${S.expectedBeak}: $_beakLabel',
                    style: const TextStyle(fontSize: 11),
                  ),
                  if (_fatherBird != null && _motherBird != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${S.father}: ${_fatherBird!.name} • '
                      '${S.mother}: ${_motherBird!.name}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.muted),
                    ),
                  ],
                  const SizedBox(height: 10),
                  ExpansionTile(
                    title: Text(
                      S.parentGenotypes,
                      style: const TextStyle(fontSize: 11),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 6),
                    children: [
                      _genotypeLine(S.father, _fatherGenotype),
                      _genotypeLine(S.mother, _motherGenotype),
                      Text(
                        S.approximateMapping,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
