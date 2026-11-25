import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'family_tree.dart';
import 'l10n.dart';
import 'models.dart';
import 'pdf_export.dart';
import 'storage.dart';
import 'theme.dart';
import 'widgets.dart';

/// عرض نسب ثنائي: خط الأب وخط الأم منفصلان، حتى خمسة أجيال.
class PedigreePage extends StatefulWidget {
  const PedigreePage({super.key, required this.onChanged});

  final VoidCallback onChanged;

  @override
  State<PedigreePage> createState() => _PedigreePageState();
}

class _PedigreePageState extends State<PedigreePage> {
  String? _selected;
  String? _other;
  int _generations = 5;

  Future<void> _sharePdf() async {
    final birds = Store.instance.birds;
    final selected = Store.instance.find(_selected) ??
        (birds.isEmpty ? null : birds.first);
    if (selected == null) return;
    final path = await PdfExporter.pedigreeReport(selected);
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(path)],
        subject: S.pedigreePdf,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final birds = Store.instance.birds;
    if (birds.isEmpty) {
      return EmptyState(
        icon: Icons.family_restroom_outlined,
        title: S.noPedigree,
        subtitle: S.noPedigreeSub,
      );
    }

    final selected = Store.instance.find(_selected) ?? birds.first;
    if (_other != null && Store.instance.find(_other) == null) _other = null;
    final byId = Store.instance.byId;
    final relation = _other == null
        ? null
        : kinship(selected.id, _other, byId);
    final inbreeding = inbreedingCoefficient(selected, byId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: selected.id,
          decoration: InputDecoration(
            labelText: S.selectBird,
            prefixIcon: const Icon(Icons.pets_outlined),
          ),
          items: [
            for (final b in birds)
              DropdownMenuItem<String>(value: b.id, child: Text(b.name)),
          ],
          onChanged: (v) => setState(() => _selected = v),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: S.familyTree,
          icon: Icons.family_restroom_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.tapToOpen,
                style: const TextStyle(fontSize: 11, color: AppTheme.muted),
              ),
              const SizedBox(height: 12),
              CoupleTree(
                father: Store.instance.find(selected.fatherId),
                mother: Store.instance.find(selected.motherId),
                children: _siblings(selected),
                highlightId: selected.id,
                onTap: (b) => setState(() => _selected = b.id),
              ),
            ],
          ),
        ),
        SectionCard(
          title: S.partnersChildren,
          icon: Icons.child_care_outlined,
          child: _offspring(selected),
        ),
        SectionCard(
          title: S.bilateral,
          icon: Icons.account_tree_outlined,
          trailing: DropdownButton<int>(
            value: _generations,
            items: const [
              DropdownMenuItem<int>(value: 3, child: Text('3')),
              DropdownMenuItem<int>(value: 4, child: Text('4')),
              DropdownMenuItem<int>(value: 5, child: Text('5')),
            ],
            onChanged: (v) => setState(() => _generations = v ?? 5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.bilateralSub,
                style: const TextStyle(fontSize: 11, color: AppTheme.muted),
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _line(
                        selected.fatherId,
                        S.paternalLine,
                        AppTheme.purple,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _line(
                        selected.motherId,
                        S.maternalLine,
                        AppTheme.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SectionCard(
          title: S.relation,
          icon: Icons.health_and_safety_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: _other,
                decoration: InputDecoration(
                  labelText: S.selectBird,
                  prefixIcon: const Icon(Icons.compare_arrows_outlined),
                ),
                items: [
                  DropdownMenuItem<String?>(value: null, child: Text(S.none)),
                  ...birds
                      .where((b) => b.id != selected.id)
                      .map(
                        (b) =>
                            DropdownMenuItem<String?>(value: b.id, child: Text(b.name)),
                      ),
                ],
                onChanged: (v) => setState(() => _other = v),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RingGauge(
                    label: S.relationValue,
                    value: relation,
                    color: AppTheme.purple,
                  ),
                  RingGauge(
                    label: S.inbreeding,
                    value: inbreeding,
                    color: _riskColor(inbreeding),
                    caption: _riskText(inbreeding),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _sharePdf,
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: Text(S.pedigreePdf),
          ),
        ),
      ],
    );
  }

  Widget _line(String? id, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          _ancestor(id, 1, color),
        ],
      ),
    );
  }

  Widget _ancestor(String? id, int depth, Color color) {
    final bird = Store.instance.find(id);
    if (bird == null || depth > _generations) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          S.notRegistered,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: AppTheme.muted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: depth == 1 ? color.withValues(alpha: 0.14) : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bird.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppTheme.navy,
                ),
              ),
              Text(
                <String>[
                  if (bird.kind.isNotEmpty) bird.kind,
                  if (bird.ring.isNotEmpty) '${S.ring} ${bird.ring}',
                  formatDate(bird.bornOn),
                ].join(' • '),
                style: const TextStyle(fontSize: 9, color: AppTheme.muted),
              ),
              Text(
                '${S.generation} $depth',
                style: TextStyle(fontSize: 9, color: color),
              ),
            ],
          ),
        ),
        if (depth < _generations &&
            (bird.fatherId != null || bird.motherId != null)) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ancestor(bird.fatherId, depth + 1, color)),
              const SizedBox(width: 6),
              Expanded(child: _ancestor(bird.motherId, depth + 1, color)),
            ],
          ),
        ],
      ],
    );
  }

  Color _riskColor(double v) {
    if (v < 0.0625) return const Color(0xFF2E9E5B);
    if (v < 0.125) return AppTheme.gold;
    return const Color(0xFFD64545);
  }

  String _riskText(double v) {
    final t = v < 0.0625 ? S.riskLow : (v < 0.125 ? S.riskMid : S.riskHigh);
    return '${S.risk}: $t';
  }

  /// الإخوة الأشقاء (نفس الأب ونفس الأم) مع الطير نفسه.
  List<Bird> _siblings(Bird b) {
    if (b.fatherId == null && b.motherId == null) return <Bird>[b];
    final list = Store.instance.birds
        .where((x) => x.fatherId == b.fatherId && x.motherId == b.motherId)
        .toList();
    if (!list.any((x) => x.id == b.id)) list.add(b);
    list.sort((a, c) => a.bornOn.compareTo(c.bornOn));
    return list;
  }

  /// لكل شريك: زوجان وأبناؤهما.
  Widget _offspring(Bird me) {
    final kids = Store.instance.birds
        .where((b) => b.fatherId == me.id || b.motherId == me.id)
        .toList();
    if (kids.isEmpty) {
      return Text(
        S.noChildren,
        style: const TextStyle(fontSize: 12, color: AppTheme.muted),
      );
    }
    final groups = <String, List<Bird>>{};
    for (final k in kids) {
      final asFather = k.fatherId == me.id;
      final other = asFather ? k.motherId : k.fatherId;
      groups.putIfAbsent('${asFather ? 'f' : 'm'}|${other ?? ''}', () => <Bird>[]).add(k);
    }
    return Column(
      children: [
        for (final e in groups.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _group(me, e.key, e.value),
          ),
      ],
    );
  }

  Widget _group(Bird me, String key, List<Bird> kids) {
    final asFather = key.startsWith('f');
    final otherId = key.substring(2);
    final other = otherId.isEmpty ? null : Store.instance.find(otherId);
    kids.sort((a, c) => a.bornOn.compareTo(c.bornOn));
    return CoupleTree(
      father: asFather ? me : other,
      mother: asFather ? other : me,
      children: kids,
      highlightId: me.id,
      onTap: (b) => setState(() => _selected = b.id),
    );
  }
}
