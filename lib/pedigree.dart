import 'package:flutter/material.dart';

import 'l10n.dart';
import 'models.dart';
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
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _metric(
                    S.relationValue,
                    relation == null ? '—' : '${(relation * 100).toStringAsFixed(1)} %',
                  ),
                  _metric(
                    S.inbreeding,
                    '${(inbreeding * 100).toStringAsFixed(1)} %',
                  ),
                ],
              ),
            ],
          ),
        ),
        SectionCard(
          title: S.children,
          icon: Icons.child_care_outlined,
          child: _children(selected.id),
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

  Widget _children(String id) {
    final children =
        Store.instance.birds.where((b) => b.fatherId == id || b.motherId == id).toList();
    if (children.isEmpty) {
      return Text(
        S.noChildren,
        style: const TextStyle(fontSize: 12, color: AppTheme.muted),
      );
    }
    return Column(
      children: [
        for (final child in children)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              child.fatherId == id ? Icons.male_outlined : Icons.female_outlined,
              size: 18,
              color: child.fatherId == id ? AppTheme.purple : AppTheme.gold,
            ),
            title: Text(child.name),
            subtitle: Text(child.kind),
            onTap: () => setState(() => _selected = child.id),
          ),
      ],
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.purple,
              )),
        ],
      ),
    );
  }
}
