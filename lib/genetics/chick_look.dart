/// أشكال الفراخ المتوقعة (الشكل الظاهري الكامل) لرسمها في التزويج الاختباري.
library;

import 'breeding.dart';
import 'constants.dart';
import 'phenotype.dart';

class ChickLook {
  const ChickLook({
    required this.phenotype,
    required this.sex,
    required this.chance,
  });

  final Phenotype phenotype;
  final PigeonSex sex;
  final double chance;
}

List<ChickLook> topChickLooks(List<Offspring> offspring, {int limit = 4}) {
  final groups = <String, ChickLook>{};
  for (final item in offspring) {
    final phenotype = computePhenotype(item.genotype);
    final key = '${item.sex.value}|${phenotype.describeAr()}';
    final existing = groups[key];
    groups[key] = existing == null
        ? ChickLook(
            phenotype: phenotype,
            sex: item.sex,
            chance: item.probability,
          )
        : ChickLook(
            phenotype: existing.phenotype,
            sex: existing.sex,
            chance: existing.chance + item.probability,
          );
  }
  final list = groups.values.toList()
    ..sort((a, b) => b.chance.compareTo(a.chance));
  return limit <= 0 ? list : list.take(limit).toList();
}
