/// «سلالة المرغوبة»: يبحث بالمحرك الوراثي عن أقصر سلسلة تزاوجات من طيورك
/// الحالية للوصول إلى فرخ يحمل الصفات المطلوبة، ويقدّر البيض اللازم.
library;

import 'dart:math' as math;

import '../l10n.dart';
import '../models.dart';
import 'constants.dart';
import 'gene_catalog.dart';
import 'genes.dart';
import 'genotype.dart';
import 'mapping.dart';

/// فرد في خطة التربية: طير موجود عندك، أو فرخ متوقع من تزويج سابق.
class PlanNode {
  PlanNode({
    required this.genotype,
    required this.cost,
    required this.generation,
    this.birds = const <Bird>[],
    this.father,
    this.mother,
    this.chance = 1,
  });

  final Genotype genotype;

  /// عدد البيض المتوقع للحصول عليه (صفر للطيور الموجودة).
  final double cost;
  final int generation;
  final List<Bird> birds;
  final PlanNode? father;
  final PlanNode? mother;

  /// احتمال هذا الفرخ من كل بيضة لهذا التزويج.
  final double chance;

  bool get isSource => father == null;
  PigeonSex get sex => genotype.sex;
  String get key => genotype.toString();
}

class PlanStep {
  const PlanStep({
    required this.father,
    required this.mother,
    required this.child,
  });

  final PlanNode father;
  final PlanNode mother;
  final PlanNode child;
}

enum PlanFailure { none, missingGene, noPair, tooFar }

class BreedPlan {
  const BreedPlan({
    this.failure = PlanFailure.none,
    this.alreadyHave = const <Bird>[],
    this.steps = const <PlanStep>[],
    this.missing = const <GeneChoice>[],
    this.expectedEggs = 0,
    this.generations = 0,
  });

  final PlanFailure failure;
  final List<Bird> alreadyHave;
  final List<PlanStep> steps;
  final List<GeneChoice> missing;
  final double expectedEggs;
  final int generations;

  bool get found => failure == PlanFailure.none;
}

class _Partial {
  const _Partial(this.alleles, this.probability);

  final Map<String, List<String>> alleles;
  final double probability;
}

class _Kid {
  const _Kid(this.genotype, this.probability);

  final Genotype genotype;
  final double probability;
}

List<String> _copies(Genotype genotype, String symbol, int count) {
  final copies = genotype.get(symbol);
  if (copies.isNotEmpty) return copies;
  return List<String>.filled(count, getLocus(symbol).wildType.symbol);
}

Map<String, double> _gametes(List<String> copies) {
  final result = <String, double>{};
  for (final allele in copies) {
    result[allele] = (result[allele] ?? 0) + 1 / copies.length;
  }
  return result;
}

/// أبناء تزويج ذكر وأنثى على المواقع المطلوبة فقط (توريث مرتبط بالجنس
/// ونسبة جنس ١:١، كما في المحرك الوراثي).
List<_Kid> _offspring(Genotype father, Genotype mother, List<String> locs) {
  final merged = <String, _Kid>{};
  for (final sex in PigeonSex.values) {
    var partials = <_Partial>[const _Partial(<String, List<String>>{}, 0.5)];
    for (final symbol in locs) {
      final locus = getLocus(symbol);
      final fatherGametes = _gametes(_copies(father, symbol, 2));
      final next = <_Partial>[];
      if (locus.sexLinked) {
        final motherCopy = _copies(mother, symbol, 1).first;
        for (final f in fatherGametes.entries) {
          for (final p in partials) {
            next.add(_Partial(
              <String, List<String>>{
                ...p.alleles,
                symbol: sex == PigeonSex.female
                    ? <String>[f.key]
                    : <String>[f.key, motherCopy],
              },
              p.probability * f.value,
            ));
          }
        }
      } else {
        final motherGametes = _gametes(_copies(mother, symbol, 2));
        for (final f in fatherGametes.entries) {
          for (final m in motherGametes.entries) {
            for (final p in partials) {
              next.add(_Partial(
                <String, List<String>>{
                  ...p.alleles,
                  symbol: <String>[f.key, m.key],
                },
                p.probability * f.value * m.value,
              ));
            }
          }
        }
      }
      partials = next;
    }
    for (final p in partials) {
      final child = Genotype(sex, p.alleles);
      final key = child.toString();
      final existing = merged[key];
      merged[key] = existing == null
          ? _Kid(child, p.probability)
          : _Kid(child, existing.probability + p.probability);
    }
  }
  return merged.values.toList();
}

Genotype _restrict(Genotype full, List<String> locs) => Genotype(
      full.sex,
      <String, List<String>>{
        for (final symbol in locs) symbol: full.get(symbol),
      },
    );

bool meetsGoals(Genotype genotype, List<GeneChoice> goals) => goals
    .every((c) => genotype.expressedAllele(c.locus).symbol == c.allele);

int _needCopies(GeneChoice choice, PigeonSex sex) {
  final locus = getLocus(choice.locus);
  if (locus.sexLinked && sex == PigeonSex.female) return 1;
  var top = 0;
  for (final allele in locus.alleles.values) {
    top = math.max(top, allele.dominance);
  }
  return locus.get(choice.allele).dominance == top ? 1 : 2;
}

/// مدى القرب من الهدف (٠ إلى ١) لترتيب الأفراد واختيار الأنسب منهم.
double _progress(Genotype genotype, List<GeneChoice> goals) {
  var sum = 0.0;
  for (final c in goals) {
    if (genotype.expressedAllele(c.locus).symbol == c.allele) {
      sum += 1;
      continue;
    }
    final have = genotype.get(c.locus).where((a) => a == c.allele).length;
    final need = _needCopies(c, genotype.sex);
    sum += math.min(have, need) / need * 0.9;
  }
  return sum / goals.length;
}

void _collect(PlanNode node, Set<String> seen, List<PlanStep> out) {
  final father = node.father;
  final mother = node.mother;
  if (father == null || mother == null) return;
  if (!seen.add(node.key)) return;
  _collect(father, seen, out);
  _collect(mother, seen, out);
  out.add(PlanStep(father: father, mother: mother, child: node));
}

BreedPlan planDesiredBreed({
  required List<Bird> birds,
  required List<GeneChoice> goals,
  int maxGenerations = 4,
  int poolLimit = 40,
}) {
  if (goals.isEmpty) return const BreedPlan(failure: PlanFailure.tooFar);
  final locs = goals.map((g) => g.locus).toSet().toList();

  final grouped = <String, List<Bird>>{};
  final genotypes = <String, Genotype>{};
  final alreadyHave = <Bird>[];
  for (final bird in birds) {
    final genotype = _restrict(genotypeFor(bird), locs);
    final key = genotype.toString();
    grouped.putIfAbsent(key, () => <Bird>[]).add(bird);
    genotypes[key] = genotype;
    if (meetsGoals(genotype, goals)) alreadyHave.add(bird);
  }
  if (alreadyHave.isNotEmpty) return BreedPlan(alreadyHave: alreadyHave);

  final all = <String, PlanNode>{
    for (final entry in grouped.entries)
      entry.key: PlanNode(
        genotype: genotypes[entry.key]!,
        cost: 0,
        generation: 0,
        birds: entry.value,
      ),
  };

  final hasMale = all.values.any((n) => n.sex == PigeonSex.male);
  final hasFemale = all.values.any((n) => n.sex == PigeonSex.female);
  if (!hasMale || !hasFemale) return const BreedPlan(failure: PlanFailure.noPair);

  // الجين الذي لا يحمله أي طير عندك لا يمكن صنعه بالتزاوج؛ لا بد من شراء طير يحمله.
  final missing = <GeneChoice>[];
  for (final goal in goals) {
    final carried = all.values.any(
      (n) => n.genotype.get(goal.locus).contains(goal.allele),
    );
    if (!carried) missing.add(goal);
  }
  if (missing.isNotEmpty) {
    return BreedPlan(failure: PlanFailure.missingGene, missing: missing);
  }

  for (var round = 1; round <= maxGenerations; round++) {
    final pool = all.values.toList()
      ..sort((a, b) {
        final byProgress = _progress(b.genotype, goals)
            .compareTo(_progress(a.genotype, goals));
        return byProgress != 0 ? byProgress : a.cost.compareTo(b.cost);
      });
    final top = pool.take(poolLimit).toList();
    final males = top.where((n) => n.sex == PigeonSex.male).toList();
    final females = top.where((n) => n.sex == PigeonSex.female).toList();
    var improved = false;
    for (final male in males) {
      for (final female in females) {
        for (final kid in _offspring(male.genotype, female.genotype, locs)) {
          final cost = 1 / kid.probability + male.cost + female.cost;
          final key = kid.genotype.toString();
          final existing = all[key];
          if (existing == null || cost < existing.cost - 1e-9) {
            all[key] = PlanNode(
              genotype: kid.genotype,
              cost: cost,
              generation: math.max(male.generation, female.generation) + 1,
              father: male,
              mother: female,
              chance: kid.probability,
            );
            improved = true;
          }
        }
      }
    }
    if (!improved) break;
  }

  PlanNode? best;
  for (final node in all.values) {
    if (node.isSource || !meetsGoals(node.genotype, goals)) continue;
    if (best == null ||
        node.cost < best.cost - 1e-9 ||
        ((node.cost - best.cost).abs() <= 1e-9 &&
            node.generation < best.generation)) {
      best = node;
    }
  }
  if (best == null) return const BreedPlan(failure: PlanFailure.tooFar);

  final steps = <PlanStep>[];
  _collect(best, <String>{}, steps);
  return BreedPlan(
    steps: steps,
    expectedEggs: best.cost,
    generations: best.generation,
  );
}

/// وصف الفرد بالنسبة للأهداف: يظهر عليه، أو حامل له، أو لا يحمله.
String describePlanNode(PlanNode node, List<GeneChoice> goals) {
  final parts = <String>[];
  for (final goal in goals) {
    final shows =
        node.genotype.expressedAllele(goal.locus).symbol == goal.allele;
    final carries = node.genotype.get(goal.locus).contains(goal.allele);
    if (shows) {
      parts.add('${goal.label} (${S.geneShows})');
    } else if (carries) {
      parts.add('${goal.label} (${S.geneCarrier})');
    }
  }
  return parts.isEmpty ? '—' : parts.join(' • ');
}
