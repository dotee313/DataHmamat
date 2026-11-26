import 'package:flutter/material.dart';

import 'family_tree.dart';
import 'genetics/genetics.dart';
import 'l10n.dart';
import 'storage.dart';
import 'theme.dart';
import 'widgets.dart';

/// «سلالة المرغوبة»: اختر الصفات التي تحلم بها، ويبحث التطبيق في طيورك الحالية
/// بالمحرك الوراثي عن أقصر سلسلة تزاوجات للوصول إليها.
class DesiredBreedPage extends StatefulWidget {
  const DesiredBreedPage({super.key});

  @override
  State<DesiredBreedPage> createState() => _DesiredBreedPageState();
}

class _DesiredBreedPageState extends State<DesiredBreedPage> {
  static const int _maxGoals = 5;
  static const int _maxGenerations = 4;

  /// صفة واحدة لكل جين (الموقع الجيني).
  final Map<String, GeneChoice> _picked = <String, GeneChoice>{};
  BreedPlan? _plan;
  List<GeneChoice> _planGoals = <GeneChoice>[];
  bool _busy = false;

  void _toggle(GeneChoice choice, bool on) {
    setState(() {
      _plan = null;
      if (!on) {
        _picked.remove(choice.locus);
        return;
      }
      if (!_picked.containsKey(choice.locus) && _picked.length >= _maxGoals) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.pickGoalsHint)),
        );
        return;
      }
      _picked[choice.locus] = choice;
    });
  }

  Future<void> _search() async {
    if (_picked.isEmpty || _busy) return;
    final goals = _picked.values.toList();
    setState(() {
      _busy = true;
      _plan = null;
    });
    // يترك للواجهة فرصة إظهار مؤشر الانتظار قبل الحساب.
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final birds = Store.instance.birds
        .where((b) => b.alive && !b.isVirtual)
        .toList();
    final plan = planDesiredBreed(
      birds: birds,
      goals: goals,
      maxGenerations: _maxGenerations,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _plan = plan;
      _planGoals = goals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.desiredBreed)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: S.pickGoals,
            icon: Icons.auto_awesome_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.desiredBreedSub,
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  S.pickGoalsHint,
                  style: const TextStyle(fontSize: 10, color: AppTheme.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    for (final choice in geneChoices)
                      FilterChip(
                        showCheckmark: false,
                        selected: _picked[choice.locus]?.allele == choice.allele,
                        label: Text(
                          choice.label,
                          style: const TextStyle(fontSize: 10),
                        ),
                        onSelected: (on) => _toggle(choice, on),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _picked.isEmpty || _busy ? null : _search,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.account_tree_outlined),
                  label: Text(S.findPath),
                ),
              ],
            ),
          ),
          if (_plan != null) ...[
            const SizedBox(height: 12),
            _result(_plan!, _planGoals),
          ],
          const SizedBox(height: 10),
          Text(
            S.planNote,
            style: const TextStyle(fontSize: 10, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }

  Widget _message(String text, Color color, IconData icon) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4)),
            ),
          ],
        ),
      );

  Widget _result(BreedPlan plan, List<GeneChoice> goals) {
    const warn = Color(0xFFD64545);
    switch (plan.failure) {
      case PlanFailure.missingGene:
        return _message(
          S.missingGenesMsg(plan.missing.map((g) => g.label).join('، ')),
          warn,
          Icons.search_off_outlined,
        );
      case PlanFailure.noPair:
        return _message(S.noPairMsg, warn, Icons.pets_outlined);
      case PlanFailure.tooFar:
        return _message(
          S.tooFarMsg(_maxGenerations),
          warn,
          Icons.hourglass_empty_outlined,
        );
      case PlanFailure.none:
        break;
    }

    if (plan.alreadyHave.isNotEmpty) {
      return SectionCard(
        title: S.desiredBreed,
        icon: Icons.check_circle_outline,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.alreadyHaveIt,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (final bird in plan.alreadyHave)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BirdCircle(bird: bird, diameter: 52),
                      const SizedBox(height: 4),
                      Text(bird.name, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );
    }

    // رقم الخطوة لكل فرخ، حتى تُشير الخطوات اللاحقة إليه.
    final stepOf = <String, int>{
      for (var i = 0; i < plan.steps.length; i++) plan.steps[i].child.key: i + 1,
    };
    final eggs = plan.expectedEggs.ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: S.desiredBreed,
          icon: Icons.account_tree_outlined,
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _pill(S.generationsCount(plan.generations), AppTheme.purple),
              _pill(S.expectedEggsLabel(eggs), AppTheme.gold),
            ],
          ),
        ),
        for (var i = 0; i < plan.steps.length; i++)
          _stepCard(
            plan.steps[i],
            i + 1,
            stepOf,
            goals,
            last: i == plan.steps.length - 1,
          ),
      ],
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      );

  Widget _node(PlanNode node, Map<String, int> stepOf) {
    final isMale = node.sex == PigeonSex.male;
    final color = isMale ? AppTheme.purple : AppTheme.gold;
    final bird = node.birds.isEmpty ? null : node.birds.first;
    final extra = node.birds.length > 1 ? ' +${node.birds.length - 1}' : '';
    final fromStep = stepOf[node.key];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (bird != null)
          BirdCircle(bird: bird, diameter: 50)
        else
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(Icons.egg_alt_outlined, color: color, size: 24),
          ),
        const SizedBox(height: 4),
        Text(
          bird != null
              ? '${bird.name}$extra'
              : (fromStep == null ? '' : S.fromStep(fromStep)),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
        Text(
          isMale ? S.male : S.female,
          style: TextStyle(fontSize: 9, color: color),
        ),
      ],
    );
  }

  Widget _stepCard(
    PlanStep step,
    int number,
    Map<String, int> stepOf,
    List<GeneChoice> goals, {
    required bool last,
  }) {
    final chance = step.child.chance;
    final oneIn = (1 / chance).ceil();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SectionCard(
        title: S.stepN(number),
        icon: last ? Icons.flag_outlined : Icons.favorite_border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _node(step.father, stepOf)),
                const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Icon(Icons.add_rounded, color: AppTheme.muted),
                ),
                Expanded(child: _node(step.mother, stepOf)),
              ],
            ),
            const SizedBox(height: 6),
            Center(
              child: Icon(Icons.arrow_downward_rounded,
                  color: last ? AppTheme.gold : AppTheme.purple),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (last ? AppTheme.gold : AppTheme.purple)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (last ? AppTheme.gold : AppTheme.purple)
                      .withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${step.child.sex == PigeonSex.male ? S.male : S.female} • '
                    '${describePlanNode(step.child, goals)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${S.chickChance}: ${(chance * 100).toStringAsFixed(chance < 0.1 ? 1 : 0)}% • '
                    '${S.oneInEggs(oneIn)}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                  if (last) ...[
                    const SizedBox(height: 6),
                    Text(
                      S.finalTarget,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.gold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
